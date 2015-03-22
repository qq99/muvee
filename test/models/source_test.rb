require 'test_helper'

class SourceTest < ActiveSupport::TestCase

  test "#file_is_present_and_exists?" do
    s = Source.new(type: 'TvShowSource', raw_file_path: '/foo/bar/baz.mp4')

    refute s.file_is_present_and_exists?

    File.stubs(:exist?).returns(true)

    assert s.file_is_present_and_exists?
  end

end
