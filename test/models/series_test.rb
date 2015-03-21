require 'test_helper'

class SeriesTest < ActiveSupport::TestCase
  test "download_poster calls download_file with remote_file_path and output_file_path" do
    Series.any_instance.stubs(series_metadata: {:poster => "foo.jpg"})
    UUID.stubs(generate: "result")
    Series.any_instance.expects(:download_file).with("http://thetvdb.com/banners/foo.jpg", Series::POSTER_FOLDER.join("result.jpg")).returns(true)

    s = Series.new
    s.download_poster

    assert_equal "result.jpg", s.poster_path
  end

  test "download_fanart calls download_file with remote_file_path and output_file_path" do
    Series.any_instance.stubs(series_metadata: {:fanart => "foo.jpg"})
    UUID.stubs(generate: "result")
    Series.any_instance.expects(:download_file).with("http://thetvdb.com/banners/foo.jpg", Series::FANART_FOLDER.join("result.jpg")).returns(true)

    s = Series.new
    s.download_fanart

    assert_equal "result.jpg", s.fanart_path
  end

  test "download_banner calls download_file with remote_file_path and output_file_path" do
    Series.any_instance.stubs(series_metadata: {:banner => "foo.jpg"})
    UUID.stubs(generate: "result")
    Series.any_instance.expects(:download_file).with("http://thetvdb.com/banners/foo.jpg", Series::BANNER_FOLDER.join("result.jpg")).returns(true)

    s = Series.new
    s.download_banner

    assert_equal "result.jpg", s.banner_path
  end

  test "download_banner is filetype agnostic when saving" do
    Series.any_instance.stubs(series_metadata: {:banner => "foo.png"})
    UUID.stubs(generate: "result")
    Series.any_instance.expects(:download_file).with("http://thetvdb.com/banners/foo.png", Series::BANNER_FOLDER.join("result.png")).returns(true)

    s = Series.new
    s.download_banner

    assert_equal "result.png", s.banner_path
  end

  test "actually downloads images" do
    VCR.use_cassette 'american_dad_images' do
      s = series(:american_dad)
      s.download_images
      assert s.reload.poster_path.present?
      assert s.reload.banner_path.present?
      assert s.reload.fanart_path.present?
    end
  end

  test "will properly create association to last watched TV show" do
    s = series(:american_dad)
    e = videos(:american_dad_s01_e01)

    s.last_watched_video_id = e.id
    s.save
    s.reload
    assert_equal e, s.last_watched_video
    assert_equal e.id, s.last_watched_video.id
    assert_equal e.id, s.last_watched_video_id
  end

  def fake_remote_episodes
    [{
      SeasonNumber: 1000, # I wish ;)
      EpisodeNumber: 1,
      title: "A"
    }, {
      SeasonNumber: 1000,
      EpisodeNumber: 2,
      title: "B"
    }, {
      SeasonNumber: 1000,
      EpisodeNumber: 3,
      title: "C"
    }]
  end

  test "reanalyze will create remote episodes for the series" do
    Video.any_instance.stubs(:file_is_present_and_exists?).returns(false)
    Series.any_instance.stubs(:all_episodes_metadata).returns(fake_remote_episodes)

    s = series(:american_dad)
    assert_equal 3, s.tv_shows.local.count
    assert_equal 0, s.tv_shows.remote.count

    assert_difference 's.tv_shows.count', +3 do
      assert_difference 's.tv_shows_count', +3 do
        s.reanalyze
        s.reload
      end
    end

    assert_equal 3, s.tv_shows.local.count
    assert_equal 3, s.tv_shows.remote.count
    assert_equal 6, s.tv_shows.count
  end

  test "repeated reanalyzation will never add duplicate episodes (wrt Season&Episode)" do
    Video.any_instance.stubs(:file_is_present_and_exists?).returns(false)
    Series.any_instance.stubs(:all_episodes_metadata).returns(fake_remote_episodes)
    s = series(:american_dad)

    assert_difference 's.tv_shows.count', +3 do
      assert_difference 's.tv_shows_count', +3 do
        s.reanalyze
        s.reanalyze
        s.reload
      end
    end
  end

  test "reanalyze will update existing episodes with any new metadata" do
    show = videos(:american_dad_s01_e01)

    Video.any_instance.stubs(:file_is_present_and_exists?).returns(true)
    Series.any_instance.stubs(:all_episodes_metadata).returns([{
      SeasonNumber: show.season,
      EpisodeNumber: show.episode,
      Overview: "Something different entirely"
    }])

    s = series(:american_dad)

    assert_no_difference 's.tv_shows.count' do
      s.reanalyze
      s.reload
    end

    show.reload
    assert_equal 'local', show.status
    assert_equal 'Something different entirely', show.overview

  end
end
