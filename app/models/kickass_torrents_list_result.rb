class KickassTorrentsListResult < ExternalMetadata
  include ActiveSupport::Benchmarkable

  ENDPOINT_URL = "https://#{Figaro.env.kickass_domain}/movies/?rss=1" # https://kat.cr/movies/?rss=1&page=1

  def result_format
    :xml
  end

  def self.endpoint_url(page = 1)
    "#{ENDPOINT_URL}&page=#{page}"
  end

  def staleness_factor
    10.minutes.ago
  end

  def results
    entries = data.try(:[], :rss).try(:[], :channel).try(:[], :item) || []

    entries = [entries] if entries.kind_of? Hash

    results = entries.inject([]) do |results, entry|
      seeds = entry[:seeds].to_s.to_i
      peers = entry[:peers].to_s.to_i

      results << {
        title: entry[:title],
        seeders: seeds,
        leechers: peers,
        magnet_link: entry[:magnetURI],
        verified: entry[:verified].to_i == 1,
        author: entry[:author]
      }
      results
    end
  end

end
