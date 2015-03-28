class MovieSource < Source

  def associate_self_with_video
    guessed = Guesser::Movie.guess_from_filepath(raw_file_path)

    movie = Movie.find_or_initialize_by(
      title: guessed[:title]
    )

    unless movie.imdb_id.present?
      imdb_id = movie.search_for_imdb_id
      movie = Movie.find_or_initialize_by(imdb_id: imdb_id)
    end

    self.quality = guessed[:quality]
    self.video = movie
  end

  def reanalyze
    guessed = Guesser::Movie.guess_from_filepath(raw_file_path)
    self.quality = guessed[:quality]
    self.is_3d = guessed[:three_d]
    self.save
  end

end
