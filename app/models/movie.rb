class Movie < Video
  include DownloadFile

  before_create :guessit
  after_commit :queue_download_job
  after_create :extract_metadata
  after_create :download_poster
  after_create :examine_thumbnail_for_3d
  before_destroy :destroy_images

  scope :local, -> {where(status: "local")}
  scope :remote, -> {where(status: "remote")}

  POSTER_FOLDER = Rails.root.join('public', 'posters')

  FORMATS = {
    name_and_year: %r{
      ([\w\-\.\_\s]*)
      [\(\ \_\.\[]{1}([\d]{4})[\)\ \_\.\[]?
    }xi
  }.freeze

  def metadata
    @imdb_id ||= imdb_id || ImdbSearchResult.get(title).relevant_result(title)[:id]
    return {} if !@imdb_id
    @metadata ||= OmdbSearchResult.get(@imdb_id).data || {}
  end

  def poster_url
    "/posters/#{poster_path}"
  end

  def extract_metadata
    self.title = metadata[:Title]
    begin
      self.released_on = Time.parse(metadata[:Released]) if metadata[:Released]
    rescue
      self.released_on = nil
    end
    self.year = self.released_on.try(:year)
    self.overview = metadata[:Plot]
    self.language = metadata[:Language]
    self.country = metadata[:Country]
    self.awards = metadata[:Awards]
    self.save
  end

  def download_poster
    return if metadata[:Response] == "False"
    remote_filename = metadata[:Poster]
    return if remote_filename.blank?
    output_filename = UUID.generate(:compact) + File.extname(remote_filename)
    output_path = POSTER_FOLDER.join(output_filename)

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

    @tmdb_find ||= TmdbFindResult.get(fetch_imdb_id).data
    if result = @tmdb_find[:movie_results].first
      tmdb_id = result[:id]
      images_result = TmdbImageResult.get(tmdb_id).data
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
    else
      []
    end
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
    imdb_id || metadata[:imdbID]
  end

  def guessit
    if filename_no_extension.empty?
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
    return if raw_file_path.empty? # this is only for local movies
    self.status = "local"
    self.save

    guessit
    if self.changed?
      self.save
      extract_metadata
      download_poster
      download_fanart
    end
  end

  def redownload
    download_poster
    download_fanart
  end

  def queue_download_job
    MovieArtDownloader.perform_async(self.id)
  end

  def redownload_missing
    if self.fanarts.empty?
      download_fanart
    end
    if self.poster_path.blank?
      download_poster
    end
  end

  def destroy_images
    begin
      File.delete(POSTER_FOLDER.join(poster_path))
    rescue Exception => e
      Rails.logger.info "Series#destroy_images: #{e}"
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
