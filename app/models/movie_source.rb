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
    super
    guessed = Guesser::Movie.guess_from_filepath(raw_file_path)
    self.quality = guessed[:quality]
    self.is_3d = guessed[:three_d]
    self.save
  end

  def suggested_filename
    name = video.title
    name += " (#{video.year})" if video.title.present?
    name += " [#{quality}]" if quality.present?
    name += " 3D" if is_3d
    name.gsub!(/[^0-9A-Za-z.\(\)\[\]\-\s]/, '')
    name += " imdb_#{video.imdb_id}" if video.imdb_id.present?
    name += File.extname(raw_file_path)
  end

end
