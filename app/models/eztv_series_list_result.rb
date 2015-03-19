class EztvSeriesListResult < ExternalMetadata

  def self.search
    uri = URI.parse(self.endpoint_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # :(
    request = Net::HTTP::Get.new(uri.request_uri)
    result = http.request(request)

    page = Nokogiri::HTML(result.body)
    options = page.css('[name="SearchString"] option').select{|option| option.attributes['value'].to_s.present? }
    names = options.map{|option| option.text.strip }
    names
  end

  def self.endpoint_url
    "https://eztv.ch/"
  end

end
