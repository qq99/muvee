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
    poster_images.sort{|p| -p.vote_average}.first.url # TODO: use locale specific image
  end

  def extract_metadata
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

  def reanalyze(deep_reanalyze = false)
    super
    return unless imdb_id.present?
    extract_metadata
    TmdbMovieMetadataService.new(imdb_id).run

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
