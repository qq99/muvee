class YtsFindResult < ExternalMetadata

  def result_format
    :json
  end

  def should_fetch
    self.updated_at.blank? || (self.updated_at.present? && self.updated_at <= 2.hours.ago)
  end

  def self.endpoint_url(imdb_id)
    "https://yts.re/api/listimdb.json?imdb_id=#{imdb_id}"
  end

end
