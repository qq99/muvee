class Movie < Video
  include DownloadFile

  before_create :guessit
  after_commit :queue_download_job, on: :create
  after_create :extract_metadata
  after_create :associate_with_genres
  after_create :download_poster
  after_create :examine_thumbnail_for_3d
  before_destroy :destroy_poster

  POSTER_FOLDER = Rails.root.join('public', 'posters')

  FORMATS = {
    name_and_year: %r{
      ([\w\-\.\_\s]*)
      [\(\ \_\.\[]{1}([\d]{4})[\)\ \_\.\[]?
    }xi
  }.freeze

  def metadata
    @imdb_id ||= fetch_imdb_id || search_for_imdb_id
    return {} if @imdb_id.blank?
    @metadata ||= (TmdbMovieResult.get(@imdb_id).data || {})
  end

  def released_on_human
    if released_on
      released_on.strftime("%Y %b %-d")
    else
      ''
    end
  end

  def runtime_human
    if duration.blank? && runtime_minutes.blank?
      "Unknown"
    else
      ChronicDuration.output(duration || (runtime_minutes * 60), format: :chrono)
    end
  end

  def search_tmdb_for_id
    tmdb_movie = TmdbMovieSearchResult.get(title).sorted_by_popularity.first
    tmdb_id = tmdb_movie[:id]
  end

  def search_for_imdb_id
    return imdb_id if imdb_id.present? && imdb_id_is_accurate
    Rails.logger.info "[search_for_imdb_id] Searching TMDB for an ID for: #{title}"
    imdb_id = TmdbMovieResult.get(search_tmdb_for_id).data.try(:[], :imdb_id)
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
    self.vote_count = metadata[:vote_count]
    self.vote_average = metadata[:vote_average]
    self.overview = metadata[:overview]
    self.language = metadata[:spoken_languages].map{|d| d.values.first}.flatten.join(", ")
    self.country = metadata[:production_countries].map{|d| d.values.last}.flatten.join(", ")
    self.imdb_id = metadata[:imdb_id]
    self.save
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
    backgrounds = backgrounds.map do |bg|
      path = bg.try(:[], :file_path)
      if path
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
    posters = posters.map do |poster|
      path = poster.try(:[], :file_path)
      if path
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

    listed_genres = dedupe_genre_array(metadata[:genres].map{|g| g[:name]})
    self.genres = []
    listed_genres.each do |genre_name|
      normalized = Genre.normalized_name(genre_name)
      genre = Genre.find_by_name(normalized) || Genre.create(name: normalized)
      self.genres << genre
    end
    self.save if listed_genres.any?
  end

  def guessit
    if filename_no_extension.blank?
      self.title = "Unknown"
    else
      quality, remaining_filename = filename_without_quality(filename_no_extension)

      self.quality = quality if quality.present?

      Movie::FORMATS.each do |name, regex|
        matches = regex.match(remaining_filename)
        if matches.present?
          self.title = pretty_title matches[1]
          if matches[2].present?
            self.year = matches[2].to_i
          end
        end
      end

      if !self.title.present?
        self.title = pretty_title remaining_filename
      end
    end
  end

  def reanalyze
    return if raw_file_path.blank? # this is only for local movies
    super
    old_imdb_id = imdb_id
    self.status = "local"
    guessit unless imdb_id_is_accurate
    extract_metadata
    associate_with_genres
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

  def examine_thumbnail_for_3d
    thumb = self.thumbnails.first.presence
    if thumb && thumb.check_for_sbs_3d
      self.is_3d = true
      self.type_of_3d = "sbs"
      self.save
    end
  end
end
