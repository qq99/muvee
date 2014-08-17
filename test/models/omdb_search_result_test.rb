require 'test_helper'

class OmdbSearchResultTest < ActiveSupport::TestCase
  test "testing JSON parsing" do
    VCR.use_cassette 'true_grit' do
      result = OmdbSearchResult.get("True Grit")
      assert_equal result.raw_value[:Title], "True Grit"
      assert_equal result.raw_value[:Year], "2010"
    end
  end

  test "properly attempts to parse JSON" do
    VCR.use_cassette 'true_grit' do
      JSON.expects(:parse).once
      OmdbSearchResult.get("True Grit")
    end
  end
end
