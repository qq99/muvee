class Movie < Video
  scope :paginated, ->(page, results_per_page) { limit(results_per_page).offset(page * results_per_page) }
  scope :favorites, -> {where(is_favorite: true)}

  def poster_url
    return nil unless poster_images.present?
    poster_images.sort{|p| -p.vote_average}.first.url # TODO: use locale specific image
  end

  def remotely_fetch_votes
    if omdb_metadata.found?
      self.parental_guidance_rating = omdb_metadata.data['Rated']
      # done with tmdb now:
      # self.vote_average = omdb_metadata.data['imdbRating'].try(:to_f)
      # self.vote_count = omdb_metadata.data['imdbVotes'].try(:gsub, /[^\d]/, '').try(:to_i)
    end

    self.save
  end

  def omdb_metadata
    @omdb_metadata ||= OmdbSearchResult.get(imdb_id)
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
    # remotely_fetch_votes

    return unless deep_reanalyze

    people.map do |person|
      ReanalyzerWorker.perform_async("Person", person.id)
    end
  end

  def suggested_filename
    name = "#{title} (#{year})"
    name += " [#{quality}]" if quality.present?
    name.gsub!(/[^0-9A-Za-z.\(\)\[\]\-\s]/, '')
    name += File.extname(raw_file_path)
  end
end
