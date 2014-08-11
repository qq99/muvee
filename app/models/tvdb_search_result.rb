class TvdbSearchResult < ExternalMetadata

  def self.endpoint_url(series_name)
    "http://thetvdb.com/api/GetSeries.php?seriesname=#{series_name}"
  end

  def self.get(series_name)
    url = self.endpoint_url(CGI.escape(series_name))

    result = TvdbSearchResult.find_by_endpoint(url)
    if !result
      result = TvdbSearchResult.new
      result.endpoint = url
      result.save
    end
    result.fetch_data
    result
  end
end
