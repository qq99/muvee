class Movie < Video
  include DownloadFile
  include AssociatesSelfWithActors
  include AssociatesSelfWithGenres

  after_commit :queue_download_job, on: :create
  after_create :extract_metadata
  after_create :associate_with_genres
  after_create :associate_with_actors
  after_create :download_poster
  before_destroy :destroy_poster

  scope :paginated, ->(page, results_per_page) { limit(results_per_page).offset(page * results_per_page) }
  scope :favorites, -> {where(is_favorite: true)}

  POSTER_FOLDER = Rails.root.join('public', 'posters')

  def metadata
    @imdb_id ||= fetch_imdb_id || search_for_imdb_id
    return {} if @imdb_id.blank?
    @metadata ||= (TmdbMovieResult.get(@imdb_id).data || {})
  end

  def trailers
    TmdbVideoResult.get('movie', search_tmdb_for_id).results
  end

  def youtube_trailers
    (trailers || []).select{ |trailer| trailer[:site].downcase == 'youtube' }
  end

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
    "/posters/#{poster_path}" if poster_path.present?
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

  def download_poster
    posters = query_tmdb_posters
    return if posters.blank?

    output_filename = UUID.generate(:compact)
    output_path = POSTER_FOLDER.join(output_filename)

    remote_filename = posters.first

    if download_file(remote_filename, output_path)
      self.poster_path = output_filename
    end
    self.save
  end

  def download_fanart
    backgrounds = query_fanart_tv_fanart + query_tmdb_fanart
    backgrounds = backgrounds.compact.uniq.reject{|b| b.blank? }
    return if backgrounds.length == 0

    self.fanarts.destroy_all

    backgrounds.each do |url|
      self.fanarts.create(remote_location: url)
    end
  end

  def query_tmdb_fanart
    return [] if fetch_imdb_id.blank?

    images_result = TmdbImageResult.get(fetch_imdb_id).data
    backgrounds = images_result[:backdrops]
    return [] if backgrounds.blank?
    backgrounds = backgrounds.map do |bg|
      path = bg.try(:[], :file_path)
      if path
        path.gsub!(/^\//, '') # trim beginning slash
        "http://image.tmdb.org/t/p/original/#{path}"
      else
        nil
      end
    end
    backgrounds
  end

  def query_tmdb_posters
    return [] if fetch_imdb_id.blank?

    images_result = TmdbImageResult.get(fetch_imdb_id).data
    posters = images_result[:posters]
    return [] if posters.blank?
    posters = posters.map do |poster|
      path = poster.try(:[], :file_path)
      if path
        path.gsub!(/^\//, '') # trim beginning slash
        "http://image.tmdb.org/t/p/original/#{path}"
      else
        nil
      end
    end
    posters
  end

  def query_fanart_tv_fanart
    return [] if fetch_imdb_id.blank?

    @fanart_tv ||= FanartTvResult.get(fetch_imdb_id).data
    backgrounds = @fanart_tv[:moviebackground]
    if backgrounds.present?
      backgrounds.map{|b| b[:url]}
    else
      []
    end
  end

  def fetch_imdb_id
    imdb_id
  end

  def associate_with_genres
    return unless metadata[:genres].present?
    genres = metadata[:genres].map{|g| g[:name]}
    associate_self_with_genres(genres)
  end

  def associate_with_actors
    return unless omdb_metadata.data['Actors'].present?
    actors = omdb_metadata.data['Actors'].split(/,|\|/)
    associate_self_with_actors(actors)
  end

  def reanalyze
    super
    old_imdb_id = imdb_id
    extract_metadata
    associate_with_genres
    associate_with_actors
    actors.each(&:reanalyze)
    redownload_missing
    if imdb_id != old_imdb_id
      redownload
    end
  end

  def suggested_filename
    name = "#{title} (#{year})"
    name += " [#{quality}]" if quality.present?
    name.gsub!(/[^0-9A-Za-z.\(\)\[\]\-\s]/, '')
    name += File.extname(raw_file_path)
  end

  def redownload
    destroy_poster
    download_poster
    self.fanarts.destroy_all
    download_fanart
  end

  def queue_download_job
    MovieArtDownloader.perform_async(self.id)
  end

  def redownload_missing
    if self.fanarts.blank?
      download_fanart
    end
    if self.poster_path.blank? || !File.exist?(poster_filepath)
      download_poster
    end
  end

  def poster_filepath
    POSTER_FOLDER.join(poster_path)
  end

  def destroy_poster
    begin
      File.delete(poster_filepath)
    rescue => e
      Rails.logger.info "Movie#destroy_poster: #{e}"
    end
  end
end
