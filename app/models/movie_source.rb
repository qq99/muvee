class MovieSource < Source
  def reanalyze
    source_exists = super
    return unless source_exists
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
