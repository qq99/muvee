class YtsListResult < ExternalMetadata

  def result_format
    :json
  end

  def staleness_factor
    1.hour.ago
  end

  def self.endpoint_url(page)
    "https://yts.to/api/v2/list_movies.json?limit=20&page=#{page}"
  end

end
