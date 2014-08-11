require 'test_helper'

class ThumbnailTest < ActiveSupport::TestCase
  test "url returns an absolute url for the filename" do
    thumb = Thumbnail.new(raw_file_path: "/foo/bar/baz.jpg")
    assert_equal "/thumbnails/baz.jpg", thumb.url
  end
end
