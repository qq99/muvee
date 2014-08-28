class YtsFindResult < ExternalMetadata

  def result_format
    :json
  end

  def should_fetch
    true
  end

  def self.endpoint_url(imdb_id)
    "https://yts.re/api/listimdb.json?imdb_id=#{imdb_id}"
  end

end
