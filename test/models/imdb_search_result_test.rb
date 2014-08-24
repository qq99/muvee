require 'test_helper'

class ImdbSearchResultTest < ActiveSupport::TestCase
  test "testing JSON parsing" do
    VCR.use_cassette 'imdb_the_amazing_spiderman' do
      result = ImdbSearchResult.get("The Amazing Spiderman")
      foo = result.relevant_result("The Amazing Spiderman")
      binding.pry
    end
  end
end
