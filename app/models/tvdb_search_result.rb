class TvdbSearchResult < ExternalMetadata

  def self.endpoint_url(series_name)
    "http://thetvdb.com/api/GetSeries.php?seriesname=#{series_name}"
  end
end
