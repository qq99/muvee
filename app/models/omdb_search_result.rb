class OmdbSearchResult < ExternalMetadata

  def result_format
    :json
  end

  def self.endpoint_url(title)
    "http://www.omdbapi.com/?t=#{title}"
  end

end
