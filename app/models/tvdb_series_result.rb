class TvdbSeriesResult < ExternalMetadata

  TVDB_KEY = "C0BAA9786923CE73" # not really sensitive data

  def self.endpoint_url(tvdb_series_id)
    "http://thetvdb.com/api/#{TVDB_KEY}/series/#{tvdb_series_id}/all/"
  end

end
