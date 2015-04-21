class YtsListResult < ExternalMetadata

  def result_format
    :json
  end

  def staleness_factor
    1.hour.ago
  end

  def self.endpoint_url(page)
    "https://yts.re/api/list.json?limit=20&set=#{page}"
  end

end
