require 'test_helper'

class ThumbnailTest < ActiveSupport::TestCase

  def setup
    @two_d_image = Rails.root.join("test/fixtures/2d-source.jpg")
    @three_d_image = Rails.root.join("test/fixtures/sbs-3d.jpg")
  end
  test "url returns an absolute url for the filename" do
    thumb = Thumbnail.new(raw_file_path: "/foo/bar/baz.jpg")
    assert_equal "/thumbnails/baz.jpg", thumb.url
  end

  test "sbs 3d detection" do
    skip
    thumb = Thumbnail.new(raw_file_path: @two_d_image)
    refute thumb.check_for_sbs_3d
  end

  test "sbs 3d detection matches sbs screenshots" do
    skip
    thumb = Thumbnail.new(raw_file_path: @three_d_image)
    assert thumb.check_for_sbs_3d
  end

  test "sbs 3d detection will overwrite the original thumbnail if options are supplied" do
    skip
    thumb = Thumbnail.new(raw_file_path: @three_d_image)
    FileUtils.expects(:copy).with(thumb.send(:scaled_path), thumb.send(:thumbnail_path))
    thumb.check_for_sbs_3d(overwrite: true)
  end
end
