class TmdbVideoResult < ExternalMetadata

  def result_format
    :json
  end

  def self.endpoint_url(format, id)
    "https://api.themoviedb.org/3/#{format}/#{id}/videos?api_key=#{Figaro.env.tmdb_api_key}"
  end

  def results
    data[:results]
  end

  def sorted_by_popularity
    results.sort_by{|r| -r[:popularity]}
  end

end
