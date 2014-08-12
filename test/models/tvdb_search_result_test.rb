require 'test_helper'

class TvdbSearchResultTest < ActiveSupport::TestCase
  test "TvdbSearchResult.get() returns me a new object if it doesn't yet exist" do
    assert_difference "TvdbSearchResult.all.length", 1 do
      @result = TvdbSearchResult.get("American Dad")
    end
    assert_equal "http://thetvdb.com/api/GetSeries.php?seriesname=American+Dad", @result.endpoint
  end

  test "repeated calls to TvdbSearchResult.get() will not make new entries" do
    assert_difference "TvdbSearchResult.all.length", 1 do
      2.times do TvdbSearchResult.get("American Dad") end
    end
  end

  test "it will URL escape before submitting" do
    TvdbSearchResult.expects(:endpoint_url).with("American+Dad")
    TvdbSearchResult.any_instance.stubs(:fetch_data)
    TvdbSearchResult.get("American Dad")
  end
end
