require 'test_helper'

class VideoTest < ActiveSupport::TestCase

  def setup
    @bigBuck = Dir.getwd() + "/test/fixtures/BigBuckBunny_320x180.mp4"
    Video.any_instance.stubs(thumbnail_root_path: "/test/scratch/")
  end

  def teardown
    %x{rm #{Dir.getwd() + '/test/scratch/'}*.jpg}
  end

  test "avprobe_grab_duration_command composes a shell safe string" do
    vid = Video.create(raw_file_path: "/foo/bar/this is a test.mp4")
    assert_equal "avprobe /foo/bar/this\\ is\\ a\\ test.mp4 2>&1 | grep -Eo 'Duration: [0-9:.]*' | cut -c 11-", vid.send(:avprobe_grab_duration_command)
  end

  test "avconv_create_thumbnail_command composes a shell safe string" do
    vid = Video.create(raw_file_path: "/foo/bar/this is a test.mp4")
    assert_equal "avconv -ss 45 -i /foo/bar/this\\ is\\ a\\ test.mp4 -qscale 1 -vsync 1 -vframes 1 -y /foo/bar/this\\ is\\ baz.jpg", vid.send(:avconv_create_thumbnail_command, 45, "/foo/bar/this is baz.jpg")
  end

  test "sets duration to 0 for a file that does not exist" do
    vid = Video.create(raw_file_path: "/foo/bar/this_is_a_test.mp4")
    assert_equal 0, vid.duration
  end

  test "properly grabs duration for a file that exists" do
    vid = Video.create(raw_file_path: @bigBuck)
    assert_equal 596, vid.duration
  end

  test "#create_thumbnail creates a file, and associates that thumbnail to the video" do
    vid = Video.create(raw_file_path: @bigBuck)
    assert_difference "vid.thumbnails.length", 1 do
      vid.create_thumbnail(10)
    end
    assert vid.thumbnails.last.raw_file_path.present?
  end

  test "will call #create_thumbnail after creation of video model" do
    Video.any_instance.expects(:create_thumbnail)
    vid = Video.create(raw_file_path: @bigBuck)
  end
end
