require 'test_helper'

class MovieSourceTest < ActiveSupport::TestCase

  def movie_stubbage
    Movie.any_instance.stubs(:associate_with_genres)
    Movie.any_instance.stubs(:create_initial_thumb)
    Movie.any_instance.stubs(:shellout_and_grab_duration)
    Movie.any_instance.stubs(:extract_metadata)
    Movie.any_instance.stubs(:download_poster)
  end

  test "#create will infer the quality for TvShows" do
    movie_stubbage
    s = MovieSource.new(raw_file_path: '/foo/bar/True.Grit.2010.1080p.mp4')
    s.save

    assert_equal '1080p', s.quality
  end

  test '#create against an existing movie' do
    s = MovieSource.new(raw_file_path: '/foo/bar/True.Grit.2010.1080p.mp4')
    assert_difference 'MovieSource.count', +1 do
      assert_no_difference 'Movie.count' do
        s.save
      end
    end

    assert s.video.present?
  end

  test '#create for a new movie' do
    movie_stubbage

    s = MovieSource.new(raw_file_path: '/foo/bar/Synecdoche.NY.2008.1080p.mp4')
    assert_difference 'MovieSource.count', +1 do
      assert_difference 'Movie.count', +1 do
        s.save
      end
    end

    assert s.video.present?
  end

end
