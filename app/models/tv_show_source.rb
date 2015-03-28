class TvShowSource < Source

  def associate_self_with_video
    guessed = Guesser::TvShow.guess_from_filepath(raw_file_path)
    guessed[:title] = metadata(guessed[:title])[:SeriesName]

    show = TvShow.find_or_initialize_by(
      title: guessed[:title],
      season: guessed[:season],
      episode: guessed[:episode]
    )

    self.quality = guessed[:quality]
    self.video = show
  end

  def reanalyze
    guessed = Guesser::TvShow.guess_from_filepath(raw_file_path)
    self.quality = guessed[:quality]
    self.is_3d = guessed[:three_d]
    self.save
  end

end
