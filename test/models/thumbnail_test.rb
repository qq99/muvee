require 'test_helper'

class ThumbnailTest < ActiveSupport::TestCase
  test "url returns an absolute url for the filename" do
    thumb = Thumbnail.new(raw_file_path: "/foo/bar/baz.jpg")
    assert_equal "/thumbnails/baz.jpg", thumb.url
  end

  test "sbs 3d detection" do
    thumb = Thumbnail.new(raw_file_path: Rails.root.join("test/fixtures/2d-source.jpg"))
    refute thumb.check_for_sbs_3d
  end

  test "sbs 3d detection matches sbs screenshots" do
    thumb = Thumbnail.new(raw_file_path: Rails.root.join("test/fixtures/sbs-3d.jpg"))
    assert thumb.check_for_sbs_3d
  end
end
