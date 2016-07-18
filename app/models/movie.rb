class Movie < Video
  # after_create :extract_metadata

  scope :paginated, ->(page, results_per_page) { limit(results_per_page).offset(page * results_per_page) }
  scope :favorites, -> {where(is_favorite: true)}

  def search_tmdb_for_id
    Rails.logger.info "[search_tmdb_for_id] Searching TMDB for an ID for: #{title}"
    tmdb_movie = TmdbMovieSearchResult.get(title).sorted_by_popularity.first
    tmdb_id = tmdb_movie.try(:[], :id)
  end

  def search_for_imdb_id
    return imdb_id if imdb_id.present?
    Rails.logger.info "[search_for_imdb_id] Searching TMDB for an ID for: #{title}"
    tmdb_id = search_tmdb_for_id
    return nil if tmdb_id.blank?
    imdb_id = TmdbMovieResult.get(tmdb_id).data.try(:[], :imdb_id)
  end

  def poster_url
    return nil unless poster_images.present?
    poster_images.sort{|p| -p.vote_average}.first.path # TODO: use locale specific image
  end

  def extract_metadata
    self.title = metadata[:title]
    begin
      self.released_on = Time.parse(metadata[:release_date]) if metadata[:release_date]
    rescue
      self.released_on = nil
    end
    self.runtime_minutes = metadata[:runtime]
    self.year = released_on.try(:year)
    self.tagline = metadata[:tagline]
    self.vote_count = metadata[:vote_count] if metadata[:vote_count].to_i >= vote_count.to_i
    self.vote_average = metadata[:vote_average] if metadata[:vote_count].to_i >= vote_count.to_i
    self.overview = metadata[:overview]
    self.language = metadata[:spoken_languages].map{|d| d.values.first}.flatten.join(", ") if metadata[:spoken_languages].present?
    self.country = metadata[:production_countries].map{|d| d.values.last}.flatten.join(", ") if metadata[:production_countries].present?
    self.imdb_id = metadata[:imdb_id] unless imdb_id.present?

    if omdb_metadata.found?
      self.parental_guidance_rating = omdb_metadata.data['Rated']
      self.vote_average = omdb_metadata.data['imdbRating'].try(:to_f)
      self.vote_count = omdb_metadata.data['imdbVotes'].try(:gsub, /[^\d]/, '').try(:to_i)
    end

    self.save
  end

  def omdb_metadata
    @omdb_metadata ||= OmdbSearchResult.get(imdb_id)
  end

  def fetch_imdb_id
    imdb_id
  end

  def reanalyze
    super
    return unless imdb_id.present?
    TmdbMovieMetadataService.new(imdb_id).run
    people.map(&:reanalyze)
    # old_imdb_id = imdb_id
    # extract_metadata
    # associate_with_genres
    # associate_with_actors
    # actors.each(&:reanalyze)
    # redownload_missing
    # if imdb_id != old_imdb_id
    #   redownload
    # end
  end

  def suggested_filename
    name = "#{title} (#{year})"
    name += " [#{quality}]" if quality.present?
    name.gsub!(/[^0-9A-Za-z.\(\)\[\]\-\s]/, '')
    name += File.extname(raw_file_path)
  end
end
