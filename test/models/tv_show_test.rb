require 'test_helper'

class TvShowTest < ActiveSupport::TestCase
  test 'can create' do
    show = TvShow.create(raw_file_path: "/foo/bar")
    assert_equal "TvShow", show.type
  end

  test '#filename_no_extension strips out the filename correctly' do
    show = TvShow.create(raw_file_path: "/foo/bar/filename.jpg")
    assert_equal "filename", show.filename_no_extension
  end

  test 'guesses something when no format matches' do
    show = TvShow.create(raw_file_path: '/foo/bar/Maggie.Simpson.in.The.Longest.Daycare.HDTV.x264-2HD.mp4')
    assert_equal "Maggie Simpson In The Longest Daycare 2 Hd", show.title

    show = TvShow.create(raw_file_path: '/foo/bar/AdventureTimeWithFinnAndJake.HDTV.x264-2HD.mp4')
    assert_equal "Adventure Time With Finn And Jake 2 Hd", show.title
  end

  test 'guesses standard format correctly on create' do
    examples = [
      "/foo/bar/Show.Name.S01E02.Source.Quality.Etc-Group.mp4",
      "/foo/bar/Show Name - S01E02 - My Ep Name.mp4",
      "/foo/bar/Show.Name.S01.E02.My.Ep.Name.mp4",
      "/foo/bar/Show.Name.S01E02E03.Source.Quality.Etc-Group.mp4",
      "/foo/bar/Show Name - S01E02-03 - My Ep Name.mp4",
      "/foo/bar/Show.Name.S01.E02.E03.mp4"
    ]

    examples.each do |name|
      show = TvShow.create(raw_file_path: name)
      assert_equal "Show Name", show.title, "Testing: #{name}"
      assert_equal 1, show.season, "Testing: #{name}"
      assert_equal 2, show.episode, "Testing: #{name}"
    end
  end
end
