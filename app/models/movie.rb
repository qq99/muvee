class Movie < Video
  include PrettyUrls
  pretty_url_by :title

  def poster_url
    return nil unless poster_images.present?
    poster_images.sort{|p| -p.vote_average}.first.url # TODO: use locale specific image
  end

  def find_tmdb_id
    TmdbMovieSearchingService.new(title).run
  end

  def resolve_duplicates
    existing_movie = Movie.find_by(tmdb_id: tmdb_id)
    if existing_movie.present?
      self.destroy
      false
    end
    true
  end

  def reanalyze(deep_reanalyze = false)
    super
    if tmdb_id.blank? && imdb_id.blank?
      self.tmdb_id = find_tmdb_id
      should_continue = resolve_duplicates
      return unless should_continue
      self.save if tmdb_id.present?
    end

    return unless imdb_id.present? || tmdb_id.present?
    TmdbMovieMetadataService.new(imdb_id, tmdb_id).run

    return unless deep_reanalyze
    people.map do |person|
      ReanalyzerWorker.perform_async(Person.name, person.id)
    end
  end

  def year
    released_on.try(:year)
  end

  def suggested_filename
    name = "#{title} (#{year})"
    name += " [#{quality}]" if quality.present?
    name.gsub!(/[^0-9A-Za-z.\(\)\[\]\-\s]/, '')
    name += File.extname(raw_file_path)
  end

end
