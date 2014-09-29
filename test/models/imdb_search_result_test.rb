require 'test_helper'

class ImdbSearchResultTest < ActiveSupport::TestCase
  test "testing JSON parsing" do
    VCR.use_cassette 'imdb_the_amazing_spiderman_matching' do
      result = ImdbSearchResult.get("The Amazing Spiderman")
      assert_equal "tt0948470", result.relevant_result("The Amazing Spiderman")
    end
  end
end
