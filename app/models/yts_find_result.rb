class YtsFindResult < ExternalMetadata

  def result_format
    :json
  end

  def staleness_factor
    2.hours.ago
  end

  def self.endpoint_url(imdb_id)
    "https://yts.to/api/v2/list_movies.json?query_term=#{imdb_id}"
  end

end
