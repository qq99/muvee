class FanartTvResult < ExternalMetadata

  API_KEY = "3470f9905d5a82d9e91023bf3562a2eb"

  def result_format
    :json
  end

  def self.endpoint_url(imdb_id)
    "http://webservice.fanart.tv/v3/movies/#{imdb_id}?api_key=#{API_KEY}"
  end

end
