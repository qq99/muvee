require 'test_helper'

class TvShowSourceTest < ActiveSupport::TestCase

  test "#create will infer the quality for TvShows" do
    fake_metadata = {
      SeriesName: 'Rick And Morty!'
    }
    Source.any_instance.stubs(:metadata).returns(fake_metadata)
    TvShow.any_instance.stubs(:metadata).returns(fake_metadata)

    s = TvShowSource.new(raw_file_path: '/foo/bar/Rick.and.Morty.S01E01.HDTV.mp4')
    s.save

    assert_equal 'HDTV', s.quality
  end

  test "#create with a non-existant TvShow creates a new video record" do
    fake_metadata = {
      SeriesName: 'Rick And Morty!'
    }
    Source.any_instance.stubs(:metadata).returns(fake_metadata)
    TvShow.any_instance.stubs(:metadata).returns(fake_metadata)

    s = TvShowSource.new(raw_file_path: '/foo/bar/Rick.and.Morty.S01E01.mp4')

    assert_difference 'TvShow.count', +1 do
      assert_difference 'TvShowSource.count', +1 do
        s.save
      end
    end

    assert_equal true, s.video.kind_of?(TvShow)
  end

  test "#create with an already existing TvShow associates the new source with that video record" do
    fake_metadata = {
      SeriesName: 'American Dad'
    }
    Source.any_instance.stubs(:metadata).returns(fake_metadata)
    TvShow.any_instance.stubs(:metadata).returns(fake_metadata)

    s = TvShowSource.new(raw_file_path: '/foo/bar/American.Dad.S01E01.HDTV.x264.mp4')

    assert_no_difference 'TvShow.count' do
      assert_difference 'TvShowSource.count', +1 do
        s.save
      end
    end
  end
end
