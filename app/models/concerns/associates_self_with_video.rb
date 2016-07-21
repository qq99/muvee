module AssociatesSelfWithVideo

  def guessed
    return @guessed if @guessed.present?

    if type.include?('Movie')
      Guesser::Movie.guess_from_filepath(raw_file_path)
    elsif type.include?('TvShow')
      Guesser::TvShow.guess_from_filepath(raw_file_path)
    end
  end

  def associate_self_with_video
    if type.include?('Movie')
      associate_self_with_movie
    elsif type.include?('TvShow')
      associate_self_with_tv_show
    end
  end

  def associate_self_with_tv_show
    return if video.present?
    show = TvShow.find_or_initialize_by(
      title: effective_tv_show_title,
      season: guessed[:season],
      episode: guessed[:episode]
    )

    self.video = show
  end

  def effective_tv_show_title
    series_title = metadata(guessed[:title])[:SeriesName]
    series_title || guessed[:title]
  end

  def associate_self_with_movie
    movie = Movie.find_or_initialize_by(
      title: guessed[:title]
    )

    if movie.tmdb_id.blank?
      found_tmdb_id = movie.find_tmdb_id
      movie = Movie.find_by(tmdb_id: found_tmdb_id) || Movie.new(
        title: guessed[:title],
        tmdb_id: found_tmdb_id
      )
    end

    self.video = movie
  end

end
