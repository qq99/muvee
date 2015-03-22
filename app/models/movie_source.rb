class MovieSource < Source

  def start_guessing
    associate_self_with_movie
  end

  def associate_self_with_movie
    guessed = Guesser::Movie.guess_from_filepath(raw_file_path)

    movie = Movie.find_or_initialize_by(
      title: guessed[:title],
      year: guessed[:year]
    )

    # guessed = Guesser::TvShow.guess_from_filepath(raw_file_path)
    # guessed[:title] = metadata(guessed[:title])[:SeriesName]
    #
    # show = TvShow.find_or_initialize_by(
    # title: guessed[:title],
    # season: guessed[:season],
    # episode: guessed[:episode]
    # )
    #
    self.quality = guessed[:quality]
    self.video = movie
  end

end
