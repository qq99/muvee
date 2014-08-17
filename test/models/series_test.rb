require 'test_helper'

class SeriesTest < ActiveSupport::TestCase
  test "download_poster calls download_file_from_tvdb with remote_file_path and output_file_path" do
    Series.any_instance.stubs(series_metadata: {:poster => "foo.jpg"})
    UUID.stubs(generate: "result")
    Series.any_instance.expects(:download_file_from_tvdb).with("foo.jpg", Series::POSTER_FOLDER.join("result.jpg")).returns(true)

    s = Series.new
    s.download_poster

    assert_equal "result.jpg", s.poster_path
  end

  test "download_fanart calls download_file_from_tvdb with remote_file_path and output_file_path" do
    Series.any_instance.stubs(series_metadata: {:fanart => "foo.jpg"})
    UUID.stubs(generate: "result")
    Series.any_instance.expects(:download_file_from_tvdb).with("foo.jpg", Series::FANART_FOLDER.join("result.jpg")).returns(true)

    s = Series.new
    s.download_fanart

    assert_equal "result.jpg", s.fanart_path
  end

  test "download_banner calls download_file_from_tvdb with remote_file_path and output_file_path" do
    Series.any_instance.stubs(series_metadata: {:banner => "foo.jpg"})
    UUID.stubs(generate: "result")
    Series.any_instance.expects(:download_file_from_tvdb).with("foo.jpg", Series::BANNER_FOLDER.join("result.jpg")).returns(true)

    s = Series.new
    s.download_banner

    assert_equal "result.jpg", s.banner_path
  end

  test "download_banner is filetype agnostic when saving" do
    Series.any_instance.stubs(series_metadata: {:banner => "foo.png"})
    UUID.stubs(generate: "result")
    Series.any_instance.expects(:download_file_from_tvdb).with("foo.png", Series::BANNER_FOLDER.join("result.png")).returns(true)

    s = Series.new
    s.download_banner

    assert_equal "result.png", s.banner_path
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
end
