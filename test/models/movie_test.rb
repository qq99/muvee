require 'test_helper'

class MovieTest < ActiveSupport::TestCase
  test "is possible to grab metadata for a movie" do
    VCR.use_cassette "true_grit" do
      movie = videos(:true_grit)
      assert_equal movie.metadata[:Year], "2010"
      assert_equal movie.metadata[:Language], "English"
    end
  end

  test "will attempt to grab duration & create initial thumbnail on create" do
    Movie.any_instance.expects(:create_initial_thumb).once
    Movie.any_instance.expects(:shellout_and_grab_duration).once
    Movie.create(raw_file_path: "/foo/bar/Truer.Grit.mp4")
  end

  test "can download posters" do
    VCR.use_cassette "true_grit_poster" do
      movie = videos(:true_grit)
      movie.download_poster
      assert movie.reload.poster_path.present?
    end
  end
end
