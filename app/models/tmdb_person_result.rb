class TmdbPersonResult < ExternalMetadata

  def result_format
    :json
  end

  def self.endpoint_url(tmdb_id)
    "https://api.themoviedb.org/3/person/#{tmdb_id}?api_key=#{Figaro.env.tmdb_api_key}"
  end

end
