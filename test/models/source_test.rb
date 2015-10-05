require 'test_helper'

class SourceTest < ActiveSupport::TestCase

  setup do
    @source = Source.new(raw_file_path: '/foo/bar/baz.mp4')
  end

  test "#file_is_present_and_exists?" do
    refute @source.file_is_present_and_exists?

    File.stubs(:exist?).returns(true)

    assert @source.file_is_present_and_exists?
  end

  test "#file_is_present_and_exists? does not attempt to look at FS if raw_file_path is blank" do
    s = Source.new

    File.expects(:exist?).never
    refute s.file_is_present_and_exists?
  end

  test "triggers post_sourced_actions on video after create" do
    Video.any_instance.expects(:shellout_and_grab_duration).once
    Video.any_instance.expects(:create_initial_thumb).once
    s = Source.create(type: 'TvShowSource', raw_file_path: '/foo/bar/baz.mp4')
  end

  test "#move_to successful move" do
    new_path = Dir.getwd() + "/tmp/new.path.mp4"

    FileUtils.expects(:mv).with(@source.raw_file_path, new_path)
    @source.expects(:update_attribute).with(:raw_file_path, new_path)

    @source.move_to(new_path)
  end

  test "#move_to unsuccessful file move" do
    new_path = Dir.getwd() + "/tmp/new.path.mp4"

    FileUtils.expects(:mv).with(@source.raw_file_path, new_path).raises(StandardError)
    @source.expects(:update_attribute).never

    assert_raises StandardError do
      @source.move_to(new_path)
    end
  end

  test "#filename" do
    assert_equal 'baz.mp4', @source.filename
  end

  test "#containing_folder" do
    assert_equal '/foo/bar/', @source.containing_folder
  end

  test "#extension" do
    assert_equal 'mp4', @source.extension
  end

  test '#rename successful' do
    new_path = '/foo/bar/wat.mp4'
    FileUtils.expects(:mv).with(@source.raw_file_path, new_path)
    @source.expects(:update_attribute).with(:raw_file_path, new_path)
    @source.rename('wat.mp4')
  end

end
