class TvdbSeriesResult < ExternalMetadata

  def self.endpoint(tvdb_series_id)
    "http://thetvdb.com/api/#{TVDB_KEY}/series/#{series_id}/all/"
  end

end
