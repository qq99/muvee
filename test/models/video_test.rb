require 'test_helper'

class VideoTest < ActiveSupport::TestCase

  def setup
    @bigBuck = Dir.getwd() + "/test/fixtures/BigBuckBunny_320x180.mp4"
    Video.any_instance.stubs(thumbnail_root_path: "/test/scratch/")
  end

  def after_tests
    Video.destroy_all
    Thumbnail.destroy_all
  end

  test "#reset_status" do
    fake_metadata = {
      SeriesName: 'American Dad'
    }
    Source.any_instance.stubs(:metadata).returns(fake_metadata)
    TvShow.any_instance.stubs(:metadata).returns(fake_metadata)

    vid = videos(:american_dad_s09_e09_sourceless)
    vid.status = nil
    vid.reset_status

    assert_equal 'remote', vid.status

    vid.sources << TvShowSource.create(raw_file_path: '/foo/bar/American.Dad.S09E09.mp4')
    vid.reload
    vid.reset_status

    assert_equal 'local', vid.status
  end

  test "avprobe_grab_duration_command composes a shell safe string" do
    vid = videos(:big_buck_bunny)
    vid.stubs(:raw_file_path).returns("/foo/bar/this is a test.mp4")
    assert_equal "avprobe /foo/bar/this\\ is\\ a\\ test.mp4 2>&1 | grep -Eo 'Duration: [0-9:.]*' | cut -c 11-", vid.send(:avprobe_grab_duration_command)
  end

  test "avconv_create_thumbnail_command composes a shell safe string" do
    vid = videos(:big_buck_bunny)
    vid.stubs(:raw_file_path).returns("/foo/bar/this is a test.mp4")
    assert_equal "avconv -loglevel quiet -ss 45 -i /foo/bar/this\\ is\\ a\\ test.mp4 -qscale 1 -vsync 1 -vframes 1 -y /foo/bar/this\\ is\\ baz.jpg", vid.send(:avconv_create_thumbnail_command, 45, "/foo/bar/this is baz.jpg")
  end

  test "sets duration to nil for a file that does not exist" do
    vid = Video.create(title: "Foo bar")
    assert_equal nil, vid.duration
  end

  test "properly grabs duration for a file that exists" do
    vid = videos(:big_buck_bunny)
    vid.stubs(:raw_file_path).returns(@bigBuck)
    vid.shellout_and_grab_duration
    assert_equal 596, vid.duration
  end

  test "#create_thumbnail creates a file, and associates that thumbnail to the video" do
    vid = videos(:big_buck_bunny)
    vid.stubs(:raw_file_path).returns(@bigBuck)
    assert_difference "vid.thumbnails.length", 1 do
      vid.create_thumbnail(10)
    end
    assert vid.thumbnails.last.raw_file_path.present?
  end

  test "#create_thumbnail will log an error if it could not create a thumbnail" do
    vid = videos(:american_dad_s01_e01)
    vid.stubs(:raw_file_path).returns('/foo/bar')
    Rails.logger.expects(:error).once
    vid.create_thumbnail(1)
  end

  test "#create_n_thumbnails will create N thumbnails" do
    vid = videos(:big_buck_bunny)
    vid.stubs(:raw_file_path).returns(@bigBuck)
    vid.shellout_and_grab_duration
    vid.save
    assert_difference "vid.thumbnails.length", 10 do
      vid.create_n_thumbnails(10)
    end
  end

end
