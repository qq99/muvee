class EztvSearchResult < ExternalMetadata

  HOST = 'eztv.ch'

  def self.search(query)
    # begin
      uri = URI.parse(self.endpoint_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE # :(
      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data({"SearchString1" => query, "search" => "Search"})
      request.add_field(':host', HOST)
      request.add_field(':method', 'POST')
      request.add_field(':path', '/search/')
      request.add_field(':scheme', 'https')
      request.add_field(':version', 'HTTP/1.1')
      request.add_field(':accept', 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8')
      request.add_field('origin', "https://#{HOST}")
      request.add_field('referer', "https://#{HOST}/search/")
      result = http.request(request)
    # rescue
      # nil
    # end

    result

    #begin
      page = Nokogiri::HTML(result.body)
      results_table = page.css('table').select{|table| table.css('.section_post_header').text.strip == 'Television Show Releases' }
      magnet_rows = results_table.first.css('tr').select{|el| el.css('a.magnet').size > 0 }

      results = []
      magnet_rows.each do |row|
        title = row.css(".epinfo").text.strip
        magnet_link = row.css(".magnet").first.attributes["href"].to_s
        results << {
          title: title,
          magnet_link: magnet_link
        }
      end
      results.each do |entry|
        entry[:guessed] = Guesser::TvShow.guess_from_string(entry[:title])
      end

      guessed_query = Guesser::TvShow.guess_from_string(query)

      results.reject! do |entry|
        entry[:guessed][:title].blank? || entry[:guessed][:season].blank? || entry[:guessed][:episode].blank?
      end
      results.reject! do |entry|
        Ldistance.compute(entry[:guessed][:title], guessed_query[:title] || '') > 3
      end
      results
    #rescue
      #[]
    #end

  end

  def self.endpoint_url
    "https://#{HOST}/search/"
  end

end
