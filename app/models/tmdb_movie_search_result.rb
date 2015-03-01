class TmdbMovieSearchResult < ExternalMetadata

  TMDB_API_KEY = "a533c4925884599fa704aaf5a9006983"

  def result_format
    :json
  end

  def self.endpoint_url(title)
    "https://api.themoviedb.org/3/search/movie?query=#{CGI::escape(title)}&api_key=#{TMDB_API_KEY}"
  end

  def results
    data[:results]
  end

  def sorted_by_popularity
    results.sort_by{|r| -r[:popularity]}
  end

end
