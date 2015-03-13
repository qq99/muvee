require 'test_helper'

class GuesserTest < ActiveSupport::TestCase

  def setup

  end

  test '#filename_without_extension' do
    assert_equal "filename", Guesser.filename_without_extension("/foo/bar/filename.jpg")
  end

  test '#guess_quality' do
    %w(1080p 720p hdtv).each do |quality|
      assert_equal quality, Guesser.guess_quality("/some/random/padding/ShowName.S01.E01.#{quality}.mp4")
    end
  end

  test '#containing_folder' do
    assert_equal "foobar", Guesser.containing_folder("/foo/bar/foobar/baz.mp4")
  end

  test '#strip_scene_stuff' do
    assert_equal 'foo', Guesser.strip_scene_stuff("foox264")
  end

  test '#guess_from_filepath guesses something when no format matches' do
    filepath = '/foo/bar/Maggie.Simpson.in.The.Longest.Daycare.HDTV.x264-2HD.mp4'
    result = Guesser::TvShow.guess_from_filepath(filepath)
    assert_equal "Maggie Simpson In The Longest Daycare 2 Hd", result[:title]
    assert_equal "HDTV", result[:quality]

    filepath = '/foo/bar/AdventureTimeWithFinnAndJake.HDTV.x264-2HD.mp4'
    result = Guesser::TvShow.guess_from_filepath(filepath)
    assert_equal "Adventure Time With Finn And Jake 2 Hd", result[:title]
    assert_equal "HDTV", result[:quality]
  end

  test '#guess_from_filepath guesses standard format correctly' do
    examples = [
      "/foo/bar/Show.Name.S01E02.Source.Quality.Etc-Group.mp4",
      "/foo/bar/Show Name - S01E02 - My Ep Name.mp4",
      "/foo/bar/Show.Name.S01.E02.My.Ep.Name.mp4",
      "/foo/bar/Show.Name.S01E02E03.Source.Quality.Etc-Group.mp4",
      "/foo/bar/Show Name - S01E02-03 - My Ep Name.mp4",
      "/foo/bar/Show.Name.S01.E02.E03.mp4"
    ]

    examples.each do |name|
      result = Guesser::TvShow.guess_from_filepath(name)
      assert_equal "Show Name", result[:title], "while testing: #{name}"
      assert_equal 1, result[:season], "while testing: #{name}"
      assert_equal 2, result[:episode], "while testing: #{name}"
    end
  end


  test '#guess_from_filepath guesses standard repeat format correctly on create' do
    filepath = "/foo/bar/Adventure Time S05E01-S05E02 Finn The Human + Jake The Dog (1920x1080) [Phr0stY].mkv"
    result = Guesser::TvShow.guess_from_filepath(filepath)
    assert_equal "Adventure Time", result[:title]
    assert_equal 5, result[:season]
    assert_equal 1, result[:episode]
    assert_equal 5, result[:season2]
    assert_equal 2, result[:episode2]
  end

  test '#guess_from_filepath guesses format when rippers suck at naming files (look at folder name)' do
    filepath = "/foo/bar/TV/The Last Ship S01E02 HDTV x264-LOL[ettv]/lol.mp4"
    result = Guesser::TvShow.guess_from_filepath(filepath)

    assert_equal "The Last Ship", result[:title]
    assert_equal 1, result[:season]
    assert_equal 2, result[:episode]
  end

  test '#guess_from_filepath guesses fov format' do
    filepath = "/foo/bar/Rick and Morty - 1x11 - Ricksy Business.webm"
    result = Guesser::TvShow.guess_from_filepath(filepath)
    assert_equal "Rick And Morty", result[:title]
    assert_equal 1, result[:season]
    assert_equal 11, result[:episode]

    filepath = "/foo/bar/Rick and Morty - 1x06 - Rick Potion #9.webm"
    result = Guesser::TvShow.guess_from_filepath(filepath)
    assert_equal "Rick And Morty", result[:title]
    assert_equal 1, result[:season]
    assert_equal 6, result[:episode]

    filepath = "/foo/bar/Archer (2009) - 1x08 - The Rock.mp4"
    result = Guesser::TvShow.guess_from_filepath(filepath)
    assert_equal "Archer (2009)", result[:title]
    assert_equal 1, result[:season]
    assert_equal 8, result[:episode]

    filepath = "/foo/bar/The Simpsons [21x15] Stealing First Base.mp4"
    result = Guesser::TvShow.guess_from_filepath(filepath)
    assert_equal "The Simpsons", result[:title]
    assert_equal 21, result[:season]
    assert_equal 15, result[:episode]
  end

  # is this acceptable?
  test '#guess_from_string guesses something when no format matches' do
    filepath = 'Maggie.Simpson.in.The.Longest.Daycare.HDTV.x264-2HD'
    result = Guesser::TvShow.guess_from_string(filepath)
    assert_equal "Maggie Simpson In The Longest Daycare Hdtv X264 2 Hd", result[:title]
    assert_equal "HDTV", result[:quality]

    filepath = 'AdventureTimeWithFinnAndJake.HDTV.x264-2HD'
    result = Guesser::TvShow.guess_from_string(filepath)
    assert_equal "Adventure Time With Finn And Jake Hdtv X264 2 Hd", result[:title]
    assert_equal "HDTV", result[:quality]
  end

  test '#guess_from_string guesses standard format correctly' do
    examples = [
      "Show.Name.S01E02.Source.Quality.Etc-Group.mp4",
      "Show Name - S01E02 - My Ep Name.mp4",
      "Show.Name.S01.E02.My.Ep.Name.mp4",
      "Show.Name.S01E02E03.Source.Quality.Etc-Group.mp4",
      "Show Name - S01E02-03 - My Ep Name.mp4",
      "Show.Name.S01.E02.E03.mp4"
    ]

    examples.each do |name|
      result = Guesser::TvShow.guess_from_string(name)
      assert_equal "Show Name", result[:title], "while testing: #{name}"
      assert_equal 1, result[:season], "while testing: #{name}"
      assert_equal 2, result[:episode], "while testing: #{name}"
    end
  end


  test '#guess_from_string guesses standard repeat format correctly on create' do
    filepath = "Adventure Time S05E01-S05E02 Finn The Human + Jake The Dog (1920x1080) [Phr0stY].mkv"
    result = Guesser::TvShow.guess_from_string(filepath)
    assert_equal "Adventure Time", result[:title]
    assert_equal 5, result[:season]
    assert_equal 1, result[:episode]
    assert_equal 5, result[:season2]
    assert_equal 2, result[:episode2]
  end

  test '#guess_from_string guesses format when rippers suck at naming files (look at folder name)' do
    filepath = "TV/The Last Ship S01E02 HDTV x264-LOL[ettv]/lol.mp4"
    result = Guesser::TvShow.guess_from_string(filepath)

    assert_equal "The Last Ship", result[:title]
    assert_equal 1, result[:season]
    assert_equal 2, result[:episode]
  end

  test '#guess_from_string guesses fov format' do
    filepath = "Rick and Morty - 1x11 - Ricksy Business.webm"
    result = Guesser::TvShow.guess_from_string(filepath)
    assert_equal "Rick And Morty", result[:title]
    assert_equal 1, result[:season]
    assert_equal 11, result[:episode]

    filepath = "Rick and Morty - 1x06 - Rick Potion #9.webm"
    result = Guesser::TvShow.guess_from_string(filepath)
    assert_equal "Rick And Morty", result[:title]
    assert_equal 1, result[:season]
    assert_equal 6, result[:episode]

    filepath = "Archer (2009) - 1x08 - The Rock.mp4"
    result = Guesser::TvShow.guess_from_string(filepath)
    assert_equal "Archer (2009)", result[:title]
    assert_equal 1, result[:season]
    assert_equal 8, result[:episode]

    filepath = "The Simpsons [21x15] Stealing First Base.mp4"
    result = Guesser::TvShow.guess_from_string(filepath)
    assert_equal "The Simpsons", result[:title]
    assert_equal 21, result[:season]
    assert_equal 15, result[:episode]
  end

  ### Movie

  test '#guess_from_filepath on movies' do
    filepath = "/foo/bar/Disconnect.2012.HDTV.XviD.spinzes.mp4"
    result = Guesser::Movie.guess_from_filepath(filepath)
    assert_equal "Disconnect", result[:title]
    assert_equal 2012, result[:year]
    assert_equal 'HDTV', result[:quality]

    filepath = "/foo/bar/Frozen.2013.1080p.BluRay.x264.YIFY.mp4"
    result = Guesser::Movie.guess_from_filepath(filepath)
    assert_equal "Frozen", result[:title]
    assert_equal 2013, result[:year]
    assert_equal '1080p', result[:quality]

    filepath = "/foo/bar/Glengarry.Glen.Ross.1992.720p.HDTV.x264.YIFY.mp4"
    result = Guesser::Movie.guess_from_filepath(filepath)
    assert_equal "Glengarry Glen Ross", result[:title]
    assert_equal 1992, result[:year]
    assert_equal "720p", result[:quality]

    filepath = "/foo/bar/Stoker 2013.mp4"
    result = Guesser::Movie.guess_from_filepath(filepath)
    assert_equal "Stoker", result[:title]
    assert_equal 2013, result[:year]
    assert_equal nil, result[:quality]

    filepath = "/foo/bar/The Nines[2007]DvDrip[Eng]-FXG.avi"
    result = Guesser::Movie.guess_from_filepath(filepath)
    assert_equal "The Nines", result[:title]
    assert_equal 2007, result[:year]
    assert_equal nil, result[:quality]

    filepath = "/foo/bar/The.Amazing.Spiderman.2012.1080p.BrRip.x264.YIFY.mp4"
    result = Guesser::Movie.guess_from_filepath(filepath)
    assert_equal "The Amazing Spiderman", result[:title]
    assert_equal 2012, result[:year]
    assert_equal "1080p", result[:quality]

    filepath = "/foo/bar/Inside Job.mp4"
    result = Guesser::Movie.guess_from_filepath(filepath)
    assert_equal "Inside Job", result[:title]
    assert_equal nil, result[:year]
    assert_equal nil, result[:quality]

    filepath = "/foo/bar/Khumba.2013.1080p.3D.HSBS.BluRay.x264.YIFY.mp4"
    result = Guesser::Movie.guess_from_filepath(filepath)
    assert_equal "Khumba", result[:title]
    assert_equal 2013, result[:year]
    assert_equal "1080p", result[:quality]

    filepath = "/foo/bar/Khumba.2013/movie.mp4"
    result = Guesser::Movie.guess_from_filepath(filepath)
    assert_equal "Khumba", result[:title]
    assert_equal 2013, result[:year]
    assert_equal nil, result[:quality]
  end

end
