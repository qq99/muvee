class YtsListResult < ExternalMetadata

  def result_format
    :json
  end

  def should_fetch
    true
  end

  def self.endpoint_url(page)
    "https://yts.re/api/list.json?limit=50&set=#{page}"
  end

end
