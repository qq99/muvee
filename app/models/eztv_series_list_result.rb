class EztvSeriesListResult < ExternalMetadata

  ENDPOINT_URL = "https://#{Figaro.env.eztv_domain}/"

  def self.search
    uri = URI.parse(ENDPOINT_URL)
    response = HTTParty.get(uri.to_s)
    page = Nokogiri::HTML(response.body)
    options = page.css('.tv-show-search-select option').select{|option| option.attributes['value'].to_s.present? }
    names = options.map{|option| option.text.strip }
    names
  end

end
