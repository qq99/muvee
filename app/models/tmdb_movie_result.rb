class TmdbMovieResult < ExternalMetadata

  TMDB_API_KEY = "a533c4925884599fa704aaf5a9006983"

  def result_format
    :json
  end

  def self.endpoint_url(tmdb_id)
    "https://api.themoviedb.org/3/movie/#{tmdb_id}?language=en&api_key=#{TMDB_API_KEY}"
  end

end
