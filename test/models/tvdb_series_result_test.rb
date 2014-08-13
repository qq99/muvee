require 'test_helper'

class TvdbSeriesResultTest < ActiveSupport::TestCase
  test "can properly grab a TVDB series ID" do
    search = TvdbSearchResult.get("American Dad")
    tvdb_series_id = search.data[:Data][:Series][:seriesid]

    assert_difference "TvdbSeriesResult.all.length", 1 do
      TvdbSeriesResult.get(tvdb_series_id)
      TvdbSeriesResult.get(tvdb_series_id)
      @result = TvdbSeriesResult.get(tvdb_series_id)
    end

    @result.reload
    assert_equal "American Dad!", @result.data[:Data][:Series][:SeriesName]
  end
end
