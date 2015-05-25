require 'httparty'

class EztvSearchResult
  include ActiveSupport::Benchmarkable

  HOST = 'eztv.ch'
  ENDPOINT_URL = "https://#{HOST}/search/"

  def logger
    @logger ||= Logger.new(STDOUT)
  end

  def search_eztv(query)
    uri = URI.parse(ENDPOINT_URL)

    response = self.benchmark("Querying eztv") do
      begin
        body = {
          'SearchString1' => query,
          'SearchString' => '',
          'search' => 'Search'
        }

        headers = {
          'Host' => HOST,
          'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          'Accept-Language' => 'en-US,en;q=0.5',
          'Accept-Encoding' => 'gzip, deflate',
          'Referer' => 'https://eztv.it/',
          'User-Agent' => 'Mozilla/5.0 (Windows NT 6.3; WOW64; rv:37.0) Gecko/20100101 Firefox/37.0'
        }

        HTTParty.post(uri.to_s, body: body, headers: headers)
      rescue StandardError => e # wtf HTTParty::Error not a valid constant
        puts e
        nil
      end
    end
  end

  def parse_html(response)
    results = []

    self.benchmark("Parsing HTML") do
      page = Nokogiri::HTML(response.body)
      results_table = page.css('table').select{|table| table.css('.section_post_header').text.strip == 'Television Show Releases' }
      magnet_rows = results_table.first.css('tr').select{|el| el.css('a.magnet').size > 0 }

      magnet_rows.each do |row|
        title = row.css(".epinfo").text.strip
        magnet_link = row.css(".magnet").first.attributes["href"].to_s
        results << {
          title: title,
          magnet_link: magnet_link
        }
      end
    end

    self.benchmark("Guessing parsed") do
      results.each do |entry|
        entry[:guessed] = Guesser::TvShow.guess_from_string(entry[:title])
      end
    end

    results
  end

  def filter_by_query(query, results)
    guessed_query = Guesser::TvShow.guess_from_string(query)

    self.benchmark("Rejecting empty guesses") do
      results.reject! do |entry|
        entry[:guessed][:title].blank? || entry[:guessed][:season].blank? || entry[:guessed][:episode].blank?
      end
    end
    self.benchmark("Computing Ldistance") do
      results.reject! do |entry|
        Ldistance.compute(entry[:guessed][:title], guessed_query[:title] || '') > 3
      end
    end
    self.benchmark("Rejecting non-matching season+episode") do
      results.select! do |entry|
        guessed_query[:episode] == entry[:guessed][:episode] &&
        guessed_query[:season] == entry[:guessed][:season]
      end
    end
    results
  end

  def self.search(query)
    query.gsub!(/[\(\)']/, '')
    instance = self.new
    response = instance.search_eztv(query)
    return [] if response.blank?
    results = instance.parse_html(response)
    filtered = instance.filter_by_query(query, results)
    filtered
  end

end
