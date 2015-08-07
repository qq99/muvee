class TvdbSeriesResult < ExternalMetadata

  def result_format
    :xml
  end

  def staleness_factor
    1.hours.ago
  end

  def self.endpoint_url(tvdb_series_id)
    "http://thetvdb.com/api/#{Figaro.env.tvdb_api_key}/series/#{tvdb_series_id}/all/"
  end

end
