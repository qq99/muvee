class TmdbMovieSearchResult < ExternalMetadata

  def result_format
    :json
  end

  def self.endpoint_url(title)
    "https://api.themoviedb.org/3/search/movie?query=#{CGI::escape(title)}&api_key=#{Figaro.env.tmdb_api_key}"
  end

  def results
    data[:results] || []
  end

  def sorted_by_popularity
    results.sort_by{|r| -r[:popularity]}
  end

end
