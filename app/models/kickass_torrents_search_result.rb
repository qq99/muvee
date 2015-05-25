class KickassTorrentsSearchResult < ExternalMetadata
  include ActiveSupport::Benchmarkable

  HOST = 'kickass.to'
  ENDPOINT_URL = "https://#{HOST}/usearch/"

  def result_format
    :xml
  end

  def self.endpoint_url(query)
    "#{ENDPOINT_URL}#{URI.escape(query)}/?rss=1"
  end

  def results
    entries = data.try(:[], :rss).try(:[], :channel).try(:[], :item) || []

    entries = [entries] if entries.kind_of? Hash

    results = entries.inject([]) do |results, entry|
      seeds = entry[:seeds].to_s.to_i
      peers = entry[:peers].to_s.to_i
      ratio = seeds.to_f / peers.to_f

      results << {
        title: entry[:title],
        seeds: seeds,
        peers: peers,
        ratio: ratio,
        magnet_link: entry[:magnetURI],
        verified: entry[:verified].to_i == 1,
        author: entry[:author]
      }
      results
    end

    results.sort_by! { |entry| -entry[:seeds] }.sort_by! { |entry| entry[:verified] ? -1 : 1 }
  end

end
