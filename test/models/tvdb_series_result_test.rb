require 'test_helper'

class TvdbSeriesResultTest < ActiveSupport::TestCase
  test "can properly grab a TVDB series ID" do
    search = TvdbSearchResult.get("American Dad")
    tvdb_series_id = search.data_from_xml[:Data][:Series][:seriesid]

    result = nil
    assert_difference "TvdbSeriesResult.all.length", 1 do
      result = TvdbSeriesResult.get(tvdb_series_id)
      result = TvdbSeriesResult.get(tvdb_series_id)
      result = TvdbSeriesResult.get(tvdb_series_id)
    end

    result.reload
    assert_equal "American Dad!", result.data_from_xml[:Data][:Series][:SeriesName]
  end
end
