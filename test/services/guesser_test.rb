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

  test 'TvShow#guess_from_filepath on nil or blank string' do
    result = Guesser::TvShow.guess_from_filepath(nil)
    assert_equal '', result[:title]
  end

  test '#guess_from_filepath guesses something when no format matches' do
    filepath = '/foo/bar/Maggie.Simpson.in.The.Longest.Daycare.HDTV.x264-2HD.mp4'
    result = Guesser::TvShow.guess_from_filepath(filepath)
    assert_equal "Maggie Simpson In The Longest Daycare 2hd", result[:title]
    assert_equal "HDTV", result[:quality]

    # filepath = '/foo/bar/AdventureTimeWithFinnAndJake.HDTV.x264-2HD.mp4'
    # result = Guesser::TvShow.guess_from_filepath(filepath)
    # assert_equal "Adventure Time With Finn And Jake 2hd", result[:title]
    # assert_equal "HDTV", result[:quality]
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
    assert_equal "Maggie Simpson In The Longest Daycare Hdtv X264 2hd", result[:title]
    assert_equal "HDTV", result[:quality]

    # filepath = 'AdventureTimeWithFinnAndJake.HDTV.x264-2HD'
    # result = Guesser::TvShow.guess_from_string(filepath)
    # assert_equal "Adventure Time With Finn And Jake Hdtv X264 2hd", result[:title]
    # assert_equal "HDTV", result[:quality]
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

  tv_fov_format_to_guess = [{
    string: 'Rick and Morty - 1x11 - Ricksy Business.webm',
    title: 'Rick And Morty',
    season: 1,
    episode: 11
  }, {
    string: 'Rick and Morty - 1x06 - Rick Potion #9.webm',
    title: 'Rick And Morty',
    season: 1,
    episode: 6
  }, {
    string: 'Archer (2009) - 1x08 - The Rock.mp4',
    title: 'Archer (2009)',
    season: 1,
    episode: 8
  }, {
    string: 'The Simpsons [21x15] Stealing First Base.mp4',
    title: 'The Simpsons',
    season: 21,
    episode: 15
  }]

  tv_fov_format_to_guess.each do |tv|
    test "#guess_from_string guesses fov format with #{tv[:string]}" do
      guessed = Guesser::TvShow.guess_from_string(tv[:string])
      assert_equal tv[:title], guessed[:title]
      assert_equal tv[:season], guessed[:season]
      assert_equal tv[:episode], guessed[:episode]
    end
  end

  ### Movie

  movie_filepaths_to_guess = [{
    filepath: "/foo/bar/Disconnect.2012.HDTV.XviD.spinzes.mp4",
    title: 'Disconnect',
    year: 2012,
    quality: 'HDTV'
  }, {
    filepath: '/foo/bar/Frozen.2013.1080p.BluRay.x264.YIFY.mp4',
    title: 'Frozen',
    year: 2013,
    quality: '1080p'
  }, {
    filepath: '/foo/bar/Glengarry.Glen.Ross.1992.720p.HDTV.x264.YIFY.mp4',
    title: 'Glengarry Glen Ross',
    year: 1992,
    quality: '720p'
  }, {
    filepath: '/foo/bar/Stoker 2013.mp4',
    title: 'Stoker',
    year: 2013,
    quality: nil
  }, {
    filepath: '/foo/bar/The Nines[2007]DvDrip[Eng]-FXG.avi',
    title: 'The Nines',
    year: 2007,
    quality: nil
  }, {
    filepath: '/foo/bar/The.Amazing.Spiderman.2012.1080p.BrRip.x264.YIFY.mp4',
    title: 'The Amazing Spiderman',
    year: 2012,
    quality: '1080p'
  }, {
    filepath: '/foo/bar/Inside Job.mp4',
    title: 'Inside Job',
    year: nil,
    quality: nil
  }, {
    filepath: '/foo/bar/Khumba.2013.1080p.3D.HSBS.BluRay.x264.YIFY.mp4',
    title: 'Khumba',
    year: 2013,
    quality: '1080p'
  }, {
    filepath: '/foo/bar/Khumba.2013/movie.mp4',
    title: 'Khumba',
    year: 2013,
    quality: nil
  }]

  movie_filepaths_to_guess.each do |movie|
    test "#guess_from_filepath on #{movie[:filepath]}" do
      guessed = Guesser::Movie.guess_from_filepath(movie[:filepath])
      assert_equal movie[:title], guessed[:title]
      assert_equal movie[:quality], guessed[:quality]
      assert_equal movie[:year], guessed[:year]
    end
  end

  test 'Movie#guess_from_filepath on nil or blank string' do
    result = Guesser::Movie.guess_from_filepath(nil)
    assert_equal '', result[:title]
    assert_equal nil, result[:quality]
    assert_equal nil, result[:year]
  end

  movie_strings_to_guess = [{
    string: 'Hotel Transylvania 2 2015 1080p BluRay x264 AAC-ETRG',
    title: 'Hotel Transylvania 2',
    year: 2015,
    quality: '1080p'
  }, {
    string: 'The Walk 2015 720p BluRay x265-HaxxOr',
    title: 'The Walk',
    year: 2015,
    quality: '720p'
  }, {
    string: 'Daniel 1983 iNTERNAL BDRip x264-LiBRARiANS[rarbg]',
    title: 'Daniel',
    year: 1983,
    quality: 'BDRip'
  }, {
    string: 'Duologia Kill Bill 2003-2004 BluRay 720p x264 AC3 2.0 BLUDV',
    title: 'Duologia Kill Bill',
    year: 2003,
    quality: '720p'
  }, {
    string: 'Extraction 2015 1080p WEB-DL x264 AC3-JYK',
    title: 'Extraction',
    year: 2015,
    quality: '1080p'
  }, {
    string: 'The Young Black Stallion (Family Film 2003) 720p HD',
    title: 'The Young Black Stallion',
    year: 2003,
    quality: '720p'
  }]

  movie_strings_to_guess.each do |movie|

    test "Movie#guess_from_string with #{movie[:string]}" do
      guessed = Guesser::Movie.guess_from_string(movie[:string])
      assert_equal movie[:title], guessed[:title]
      assert_equal movie[:year], guessed[:year]
      assert_equal movie[:quality], guessed[:quality]
    end
  end


  test '#guess_year with a variety of years' do
    assert_equal 1990, Guesser.guess_year('1990')
    assert_equal 2015, Guesser.guess_year('2015')
    assert_equal 2016, Guesser.guess_year('2016')
    assert_equal nil, Guesser.guess_year('2048') # too far in future
    assert_equal nil, Guesser.guess_year('1890') # too far in the past
  end

end
