class YtsListResult < ExternalMetadata

  def result_format
    :json
  end

  def should_fetch
    self.updated_at.blank? || (self.updated_at.present? && self.updated_at <= 60.minutes.ago)
  end

  def self.endpoint_url(page)
    "https://yts.re/api/list.json?limit=20&set=#{page}"
  end

end
