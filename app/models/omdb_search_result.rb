class OmdbSearchResult < ExternalMetadata

  def result_format
    :json
  end

  def self.endpoint_url(series_name)
    "http://www.omdbapi.com/?t=#{series_name}"
  end

end
