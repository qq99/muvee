require 'test_helper'

class MovieTranscodeTest < ActiveSupport::TestCase

  def movie_stubbage
    Movie.any_instance.expects(:associate_with_genres)
    Movie.any_instance.expects(:extract_metadata)
    Movie.any_instance.expects(:download_poster)
  end

  test '#create against an existing movie' do
    s = MovieTranscode.new(raw_file_path: '/foo/bar/True.Grit.2010.1080p.mp4')
    assert_difference 'MovieTranscode.count', +1 do
      assert_no_difference 'Movie.count' do
        s.save
      end
    end

    assert s.video.present?
  end

  test '#create for a new movie' do
    movie_stubbage
    Movie.any_instance.expects(:search_for_imdb_id).once.returns("tt12345")

    s = MovieTranscode.new(raw_file_path: '/foo/bar/Synecdoche.NY.2008.1080p.mp4')
    assert_difference 'MovieTranscode.count', +1 do
      assert_difference 'Movie.count', +1 do
        s.save
      end
    end

    assert s.video.present?
  end

end
