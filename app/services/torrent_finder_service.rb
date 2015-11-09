class TorrentFinderService

  def initialize(query)
    @query = query.gsub(/[\(\)']/, '')
  end

  def search

    threads = []
    # threads << search_eztv
    threads << search_kickass
    threads << search_piratebay
    threads.each(&:join)

    @results = eztv_results + kickass_results + piratebay_results
    sort_results(@results)
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

  def sort_results(results)
    results
      .sort_by! { |entry| entry[:verified] ? -1 : 1 }
      .sort_by! { |entry| -1 * (entry[:seeders] || 0) }
  end

  def categorize_results(source, results)
    results
      .each { |result| result[:source] = source }
      .each { |result|
        seeders = result[:seeders].to_s.to_i
        leechers = result[:leechers].to_s.to_i
        ratio = seeders.to_f / leechers.to_f
        result[:ratio] = ratio
      }
  end

  def search_eztv
    Thread.new {
      @eztv_results = EztvSearchResult.search(@query) || []
      categorize_results(:eztv, @eztv_results)
    }
  end

  def search_kickass
    Thread.new {
      @kickass_results = KickassTorrentsSearchResult.get(@query).results || []
      categorize_results(:kickass, @kickass_results)
    }
  end

  def search_piratebay
    Thread.new {
      @piratebay_results = ThePirateBay::Search.new(@query, 0, ThePirateBay::SortBy::Seeders, ThePirateBay::Category::Video).results || []
      categorize_results(:piratebay, @piratebay_results)
    }
  end

end
