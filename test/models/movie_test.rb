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

  test "#is_movie?" do
    movie = videos(:true_grit)
    assert movie.is_movie?
    show = videos(:american_dad_s01_e01)
    refute show.is_movie?
  end

  test "extract_metadata works" do
    VCR.use_cassette "true_grit_poster" do
      movie = videos(:true_grit)
      movie.extract_metadata
      assert_equal "True Grit", movie.title
      assert_equal Time.parse("22 Dec 2010"), movie.released_on
      assert movie.overview.present?
      assert_equal "English", movie.language
      assert_equal "USA", movie.country
      assert movie.awards.present?
    end
  end

  test "#guessit" do
    movie = Movie.new(raw_file_path: "/foo/bar/Disconnect.2012.HDTV.XviD.spinzes.mp4")
    movie.guessit
    assert_equal "Disconnect", movie.title

    movie = Movie.new(raw_file_path: "/foo/bar/Frozen.2013.1080p.BluRay.x264.YIFY.mp4")
    movie.guessit
    assert_equal "Frozen", movie.title

    movie = Movie.new(raw_file_path: "/foo/bar/Glengarry.Glen.Ross.1992.720p.HDTV.x264.YIFY.mp4")
    movie.guessit
    assert_equal "Glengarry Glen Ross", movie.title

    movie = Movie.new(raw_file_path: "/foo/bar/Stoker 2013.mp4")
    movie.guessit
    assert_equal "Stoker", movie.title

    movie = Movie.new(raw_file_path: "/foo/bar/The Nines[2007]DvDrip[Eng]-FXG.avi")
    movie.guessit
    assert_equal "The Nines", movie.title

    movie = Movie.new(raw_file_path: "/foo/bar/The.Amazing.Spiderman.2012.1080p.BrRip.x264.YIFY.mp4")
    movie.guessit
    assert_equal "The Amazing Spiderman", movie.title
  end
end
