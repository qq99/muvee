require 'test_helper'

class MovieTest < ActiveSupport::TestCase
  test "will attempt to grab duration & create initial thumbnail & extract metadata on create" do
    Movie.any_instance.expects(:create_initial_thumb).once
    Movie.any_instance.expects(:shellout_and_grab_duration).once
    Movie.any_instance.expects(:extract_metadata).once
    Movie.any_instance.expects(:download_poster).once
    Movie.any_instance.expects(:examine_thumbnail_for_3d).once
    Movie.create(raw_file_path: "/foo/bar/Truer.Grit.mp4")
  end

  test "can download posters" do
    VCR.use_cassette "download_posters_test" do
      movie = videos(:true_grit)
      movie.download_poster
      assert movie.reload.poster_path.present?
    end
  end

  test "#query_tmdb_fanart returns an array of URLs" do
    VCR.use_cassette "query_tmdb_fanart" do
      movie = videos(:true_grit)
      assert_equal Array, movie.query_tmdb_fanart.class
      assert_equal 13, movie.query_tmdb_fanart.length
    end
  end

  test "#query_tmdb_fanart returns empty array if we don't know IMDB ID" do
    movie = videos(:true_grit)
    movie.stubs(:fetch_imdb_id).returns(nil)
    assert_equal Array, movie.query_tmdb_fanart.class
    assert_equal 0, movie.query_tmdb_fanart.length
  end

  test "#query_fanart_tv_fanart returns an array of URLs" do
    VCR.use_cassette "query_fanart_tv_fanart" do
      movie = videos(:true_grit)
      assert_equal Array, movie.query_fanart_tv_fanart.class
      assert_equal 1, movie.query_fanart_tv_fanart.length
    end
  end

  test "#query_fanart_tv_fanart returns empty array if we don't know IMDB ID" do
    movie = videos(:true_grit)
    movie.stubs(:fetch_imdb_id).returns(nil)
    assert_equal Array, movie.query_fanart_tv_fanart.class
    assert_equal 0, movie.query_fanart_tv_fanart.length
  end

  test "#download_fanart will create fanart resources (that attempt to download)" do
    Fanart.any_instance.stubs(:download_image_file).returns(true)
    VCR.use_cassette "download_fanart" do
      movie = videos(:true_grit)
      assert_difference "movie.fanarts.length", 14 do
        movie.download_fanart
      end
    end
  end

  test "#is_movie?" do
    movie = videos(:true_grit)
    assert movie.is_movie?
    show = videos(:american_dad_s01_e01)
    refute show.is_movie?
  end

  test "reanalyze calls Video::reanalyze" do
    movie = videos(:true_grit)
    Video.any_instance.expects(:reanalyze).once
    movie.reanalyze
  end

  test "reanalyze sets the status of a video to local" do
    movie = videos(:true_grit)
    movie.update_attribute(:status, "remote")
    movie.reanalyze
    assert movie.local?
  end

  test "reanalyze attempts to guessit unless the imdb_id has been noted to be accurated" do
    movie = videos(:true_grit)
    Movie.any_instance.expects(:guessit).once
    movie.reanalyze
    movie.update_attribute(:imdb_id_is_accurate, true)
    movie.reanalyze
  end

  test "reanalyze will extract metadata fields into the movie" do
    VCR.use_cassette "extract_metadata_test" do
      movie = videos(:true_grit)
      movie.reanalyze
      assert_equal "True Grit", movie.title
      assert_equal Time.parse("22 Dec 2010"), movie.released_on
      assert movie.overview.present?
      assert_equal "English", movie.language
      assert_equal "USA", movie.country
      assert movie.awards.present?
    end
  end

  test "reanalyze performs a few subtasks" do
    movie = videos(:true_grit)
    Movie.any_instance.expects(:guessit).once
    Movie.any_instance.expects(:associate_with_genres).once
    Movie.any_instance.expects(:extract_metadata).once
    movie.reanalyze
  end

  test "reanalyze will attempt to redownload fanarts/videos/etc if the imdb_id changes" do
    VCR.use_cassette "extract_metadata_test" do
      movie = videos(:true_grit)
      movie.update_attribute(:imdb_id, "wat")
      Movie.any_instance.expects(:redownload).once
      movie.reanalyze
    end
  end

  test "extract_metadata works" do
    VCR.use_cassette "extract_metadata_test" do
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

  test "associate_with_genres works" do
    VCR.use_cassette "extract_metadata_test" do
      movie = videos(:true_grit)
      assert_difference "Genre.count", 3 do
        movie.associate_with_genres
      end
      assert_no_difference "Genre.count" do
        movie.associate_with_genres
      end

      assert_equal 3, movie.genres.length
    end
  end

  test "#guessit" do
    movie = Movie.new(raw_file_path: "/foo/bar/Disconnect.2012.HDTV.XviD.spinzes.mp4")
    movie.guessit
    assert_equal "Disconnect", movie.title
    assert_equal 2012, movie.year
    assert_equal nil, movie.quality

    movie = Movie.new(raw_file_path: "/foo/bar/Frozen.2013.1080p.BluRay.x264.YIFY.mp4")
    movie.guessit
    assert_equal "Frozen", movie.title
    assert_equal 2013, movie.year
    assert_equal "1080p", movie.quality

    movie = Movie.new(raw_file_path: "/foo/bar/Glengarry.Glen.Ross.1992.720p.HDTV.x264.YIFY.mp4")
    movie.guessit
    assert_equal "Glengarry Glen Ross", movie.title
    assert_equal 1992, movie.year
    assert_equal "720p", movie.quality

    movie = Movie.new(raw_file_path: "/foo/bar/Stoker 2013.mp4")
    movie.guessit
    assert_equal "Stoker", movie.title
    assert_equal 2013, movie.year
    assert_equal nil, movie.quality

    movie = Movie.new(raw_file_path: "/foo/bar/The Nines[2007]DvDrip[Eng]-FXG.avi")
    movie.guessit
    assert_equal "The Nines", movie.title
    assert_equal 2007, movie.year
    assert_equal nil, movie.quality

    movie = Movie.new(raw_file_path: "/foo/bar/The.Amazing.Spiderman.2012.1080p.BrRip.x264.YIFY.mp4")
    movie.guessit
    assert_equal "The Amazing Spiderman", movie.title
    assert_equal 2012, movie.year
    assert_equal "1080p", movie.quality

    movie = Movie.new(raw_file_path: "/foo/bar/Inside Job.mp4")
    movie.guessit
    assert_equal "Inside Job", movie.title
    assert_equal nil, movie.year
    assert_equal nil, movie.quality

    movie = Movie.new(raw_file_path: "/foo/bar/Khumba.2013.1080p.3D.HSBS.BluRay.x264.YIFY.mp4")
    movie.guessit
    assert_equal "Khumba", movie.title
    assert_equal 2013, movie.year
    assert_equal "1080p", movie.quality


  end
end
