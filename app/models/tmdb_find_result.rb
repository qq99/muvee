class TmdbFindResult < ExternalMetadata

  def result_format
    :json
  end

  def self.endpoint_url(imdb_id)
    "https://api.themoviedb.org/3/find/#{imdb_id}?api_key=#{Figaro.env.tmdb_api_key}&external_source=imdb_id"
  end

end
