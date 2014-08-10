require 'test_helper'

class TvShowTest < ActiveSupport::TestCase
  test 'can create' do
    show = TvShow.create(raw_file_path: "/foo/bar")
    assert_equal "TvShow", show.type
  end
end
