class OmdbSearchResult < ExternalMetadata

  def result_format
    :json
  end

  def self.endpoint_url(imdb_id)
    "http://www.omdbapi.com/?i=#{imdb_id}&plot=full&r=json"
  end

  def found?
    data.present? && data['Response'] != 'False'
  end

end
