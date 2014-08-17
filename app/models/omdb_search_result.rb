class OmdbSearchResult < ExternalMetadata

  def result_format
    :json
  end

  def self.endpoint_url(series_name)
    "http://www.omdbapi.com/?t=True%20Grit"
  end

end
