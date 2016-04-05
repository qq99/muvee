class TorrentFinderService

  def initialize(query)
    @query = query.gsub(/[\(\)']/, '')
  end

  def find
    hydra = Typhoeus::Hydra.new

    search_piratebay # TODO: make into hydra queue
    hydra.queue search_kickass
    hydra.run

    @results = kickass_results + piratebay_results + eztv_results
    sort_results(@results)
  end

  def search_kickass
    req = Typhoeus::Request.new(
      "https://#{Figaro.env.kickass_domain}/usearch/#{URI.escape(@query)}/",
      followlocation: true,
      accept_encoding: "gzip",
      params: {
        rss: 1
      }
    )
    req.on_complete do |response|
      if response.success?
        log 'kickass: req success'
        result = Hash.from_xml(response.body).try(:with_indifferent_access) || {}
        result = Hashie::Mash.new(result)

        entries = result.try(:rss).try(:channel).try(:item)
        entries = [entries] if entries.kind_of?(Hash)

        @kickass_results = entries.map do |entry|
          pub_date = Time.parse(entry.pubDate) if entry.pubDate.present?

          RemoteTorrent.new(
            title: entry.title,
            seeders: entry.seeds.to_s.to_i,
            leechers: entry.peers.to_s.to_i,
            magnet_link: entry.magnetURI,
            verified: entry.verified.to_s.to_i == 1,
            author: entry.author,
            category: entry.category,
            link: entry.link,
            published_at: entry.pub_date,
            filesize: entry.contentLength.to_i
          )
        end
        postprocess_results(:kickass, @kickass_results)
        @kickass_results
      elsif response.timed_out?
        log 'kickass: req timed out'
      elsif response.code == 0
        log 'kickass: something went wrong, no response code'
      else
        log "kickass: request failed: #{response.code.to_s}"
      end
    end

    req
  end

  def search_piratebay
    begin
      Timeout::timeout(5) do
        results = ThePirateBay::Search.new(@query, 0, ThePirateBay::SortBy::Seeders, ThePirateBay::Category::Video).results || []
        @piratebay_results = results.map{ |e| RemoteTorrent.new(e) }
        postprocess_results(:piratebay, @piratebay_results)
      end
    rescue Timeout::Error
      log 'piratebay: search timed out'
      []
    end
  end

  def eztv_results
    @eztv_results || []
  end

  def kickass_results
    @kickass_results || []
  end

  def piratebay_results
    @piratebay_results || []
  end

  private

  def postprocess_results(source, results)
    results.each { |result|
      result[:source] = source
    }
  end

  def sort_results(results)
    results.sort_by! { |entry| -(entry[:seeders] || 0) }
  end

  def log(message)
    puts "[TorrentFinderService] #{message}"
  end

end
