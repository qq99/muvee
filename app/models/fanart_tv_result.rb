class FanartTvResult < ExternalMetadata

  def result_format
    :json
  end

  def self.endpoint_url(imdb_id)
    "http://webservice.fanart.tv/v3/movies/#{imdb_id}?api_key=#{Figaro.env.fanart_tv_api_key}"
  end

end
