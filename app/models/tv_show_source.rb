class TvShowSource < Source

  def start_guessing
    if type == 'TvShowSource'
      associate_self_with_tv_show
    elsif type == 'MovieSource'

    end
  end

  def associate_self_with_tv_show
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

end
