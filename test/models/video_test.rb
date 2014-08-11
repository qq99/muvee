require 'test_helper'

class VideoTest < ActiveSupport::TestCase
  test "avprobe_grab_duration_command composes a shell safe string" do
    vid = Video.create(raw_file_path: "/foo/bar/this is a test.mp4")
    assert_equal "avprobe /foo/bar/this\\ is\\ a\\ test.mp4 2>&1 | grep -Eo 'Duration: [0-9:.]*' | cut -c 11-", vid.send(:avprobe_grab_duration_command)
  end

  test "sets duration to 0 for a file that does not exist" do
    vid = Video.create(raw_file_path: "/foo/bar/this_is_a_test.mp4")
    assert_equal 0, vid.duration
  end

test "properly grabs duration for a file that exists" do
    vid = Video.create(raw_file_path: Dir.getwd() + "/test/fixtures/BigBuckBunny_320x180.mp4")
    assert_equal 596, vid.duration
  end
end
