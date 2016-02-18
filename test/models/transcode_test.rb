require 'test_helper'

class TranscodeTest < ActiveSupport::TestCase

  setup do
    @transcode = transcodes(:example)
    ApplicationConfiguration.stubs(:first).returns(stub(transcode_folder: '/tmp/transcoding'))
  end

  test "#transcode_parameters when source video codec is g2g for .mp4, but audio is not" do
    Video.stubs(:get_video_encoding).returns('h264')
    Video.stubs(:get_audio_encoding).returns('something')

    expected = {
      container: '.mp4',
      video_codec: 'copy',
      audio_codec: 'libvorbis'
    }

    assert_equal expected, @transcode.transcode_parameters
  end

  test "#transcode_parameters when source video/audio codec is g2g for .mp4" do
    Video.stubs(:get_video_encoding).returns('h264')
    Video.stubs(:get_audio_encoding).returns('aac')

    expected = {
      container: '.mp4',
      video_codec: 'copy',
      audio_codec: 'copy'
    }

    assert_equal expected, @transcode.transcode_parameters
  end

  test "#transcode_parameters when source video codec not good to copy" do
    Video.stubs(:get_video_encoding).returns('xvid')
    Video.stubs(:get_audio_encoding).returns('aac')

    expected = {
      container: '.webm',
      video_codec: 'libvpx',
      audio_codec: 'libvorbis'
    }

    assert_equal expected, @transcode.transcode_parameters
  end

  test "#transcode_parameters when source video codec not good for mp4, but is good for webm" do
    Video.stubs(:get_video_encoding).returns('vp8')
    Video.stubs(:get_audio_encoding).returns('libvorbis')

    expected = {
      container: '.webm',
      video_codec: 'copy',
      audio_codec: 'copy'
    }

    assert_equal expected, @transcode.transcode_parameters
  end

  test "#filename" do
    assert_equal 'baz', @transcode.filename
  end

  test "#transcode_folder grabs from ApplicationConfiguration" do
    assert_equal '/tmp/transcoding', @transcode.transcode_folder
  end

  test "transcode_path returns a full path" do
    assert_equal '/tmp/transcoding/baz.muv-transcoding.webm', @transcode.transcode_path
  end

  test "eventual_path returns a full path" do
    assert_equal '/foo/bar/baz.muv-transcoded.webm', @transcode.eventual_path
  end

  test "#source_klass looks at the Video.type" do
    assert_equal 'TvShowSource', @transcode.source_klass
  end

  test "#transcoding?" do
    refute @transcode.transcoding?
    @transcode.update_attribute(:status, 'transcoding')
    assert @transcode.transcoding?
  end

  test "#complete?" do
    refute @transcode.complete?
    @transcode.update_attribute(:status, 'complete')
    assert @transcode.complete?
  end

  test "#failed?" do
    refute @transcode.failed?
    @transcode.update_attribute(:status, 'failed')
    assert @transcode.failed?
  end

  test "#transcode_command" do
    assert_equal "avconv -threads auto -i /foo/bar/baz.avi -loglevel quiet -c:v libvpx -qmin 0 -qmax 50 -b:v 1M -c:a libvorbis -q:a 4 /tmp/transcoding/baz.muv-transcoding.webm", @transcode.transcode_command
  end

  test "#move_transcoded_file! returns false when transcoding file does not exist" do
    File.expects(:exist?).with(@transcode.transcode_path).returns(false)
    FileUtils.expects(:mv).never
    refute @transcode.move_transcoded_file!
  end

  test "#move_transcoded_file! attempts to move the transcode_path to the eventual_path" do
    File.expects(:exist?).with(@transcode.transcode_path).returns(true)
    FileUtils.expects(:mv).with(@transcode.transcode_path, @transcode.eventual_path).returns(true)
    assert @transcode.move_transcoded_file!
  end

  test "#transcode returns early when complete?" do
    @transcode.update_attribute(:status, 'complete')

    @transcode.expects(:origin_file_exists?).returns(true)
    @transcode.expects(:perform).never
    @transcode.expects(:perform_transcode_subprocess).never
    @transcode.expects(:move_transcoded_file!).never

    assert @transcode.transcode
    assert @transcode.complete?
  end

  test "#transcode attempts to move the transcoded file when complete? and the transcoding file still exists" do
    @transcode.update_attribute(:status, 'complete')

    @transcode.expects(:origin_file_exists?).returns(true)
    @transcode.expects(:transcoding_file_exists?).once.returns(true)
    @transcode.expects(:perform).never
    @transcode.expects(:perform_transcode_subprocess).never
    @transcode.expects(:move_transcoded_file!).once

    assert @transcode.transcode
    assert @transcode.complete?
  end

  test "#transcode returns early when transcoding?" do
    @transcode.update_attribute(:status, 'transcoding')

    @transcode.expects(:origin_file_exists?).returns(true)
    @transcode.expects(:perform).never
    @transcode.expects(:perform_transcode_subprocess).never
    @transcode.expects(:move_transcoded_file!).never

    assert @transcode.transcode
    assert @transcode.transcoding?
  end

  test "#transcode deletes transcoding file when Transcode has failed, and transcoding file still exists, performs the transcode, and moves the succesful result" do
    @transcode.update_attribute(:status, 'failed')

    @transcode.expects(:origin_file_exists?).returns(true)
    @transcode.expects(:transcoding_file_exists?).at_least_once.returns(true)
    File.expects(:delete).with(@transcode.transcode_path).once.returns(true)
    @transcode.expects(:perform_transcode_subprocess).once.returns(true)
    @transcode.expects(:move_transcoded_file!).once

    assert @transcode.transcode
    assert @transcode.complete?
  end

  test "#transcode does not try to move the result if #perform_transcode_work was unsuccessful" do
    @transcode.expects(:origin_file_exists?).returns(true)
    @transcode.expects(:perform_transcode_subprocess).once.returns(false)
    @transcode.expects(:move_transcoded_file!).never

    refute @transcode.transcode
    assert @transcode.failed?
  end

end
