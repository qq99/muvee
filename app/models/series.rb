class Series < ActiveRecord::Base
  include HasMetadata
  include DownloadFile

  after_create :download_images
  before_destroy :destroy_images
  before_validation :extract_metadata, on: :create

  validates :title, presence: true

  validates_uniqueness_of :tvdb_id, allow_nil: false, allow_blank: false

  POSTER_FOLDER = Rails.root.join('public', 'posters')
  FANART_FOLDER = Rails.root.join('public', 'fanart')
  BANNER_FOLDER = Rails.root.join('public', 'banners')

  has_many :tv_shows
  has_one :tvdb_series_result
  has_one :last_watched_video, class_name: "Video", primary_key: "last_watched_video_id", foreign_key: "id"

  scope :with_episodes, -> {where('tv_shows_count > 0')}
  scope :without_episodes, -> {where('tv_shows_count = 0')}
  scope :favorites, -> {where(is_favorite: true)}
  scope :paginated, ->(page, results_per_page) { limit(results_per_page).offset(page * results_per_page) }

  def extract_metadata
    self.title = series_metadata[:SeriesName]
    self.tvdb_id = series_metadata[:id].to_i
    self.overview = series_metadata[:Overview]
    self.tvdb_rating = series_metadata[:Rating]
    self.tvdb_rating_count = series_metadata[:RatingCount]
    self.status = series_metadata[:Status]
    #self.tvdb_series_result = episode_metadata_search
    self
  end

  def first_aired
    series_metadata[:FirstAired]
  end

  def network
    series_metadata[:Network]
  end

  def IMDB_id
    series_metadata[:IMDB_ID]
  end

  def poster_url
    "/posters/#{poster_path}" if poster_path.present?
  end

  def fanart_url
    "/fanart/#{fanart_path}" if fanart_path.present?
  end

  def banner_url
    "/banners/#{banner_path}" if banner_path.present?
  end

  def download_images
    download_fanart
    download_banner
    download_poster
    self.save
  end

  def download_fanart
    return if series_metadata[:fanart].blank?

    remote_filename = "http://thetvdb.com/banners/" + series_metadata[:fanart]
    output_filename = UUID.generate(:compact) + File.extname(remote_filename)
    output_path = FANART_FOLDER.join(output_filename)

    if download_file(remote_filename, output_path)
      self.fanart_path = output_filename
    end
  end

  def download_banner
    return if series_metadata[:banner].blank?

    remote_filename = "http://thetvdb.com/banners/" + series_metadata[:banner]
    output_filename = UUID.generate(:compact) + File.extname(remote_filename)
    output_path = BANNER_FOLDER.join(output_filename)

    if download_file(remote_filename, output_path)
      self.banner_path = output_filename
    end
  end

  def download_poster
    return if series_metadata[:poster].blank?

    remote_filename = "http://thetvdb.com/banners/" + series_metadata[:poster]
    output_filename = UUID.generate(:compact) + File.extname(remote_filename)
    output_path = POSTER_FOLDER.join(output_filename)

    if download_file(remote_filename, output_path)
      self.poster_path = output_filename
    end
  end

  def destroy_images
    begin
      File.delete(POSTER_FOLDER.join(poster_path))
      File.delete(BANNER_FOLDER.join(banner_path))
      File.delete(FANART_FOLDER.join(fanart_path))
    rescue => e
      Rails.logger.info "Series#destroy_images: #{e}"
    end
  end

  def reanalyze
    extract_metadata
    self.save
    all_episodes_metadata.each do |ep|
      show = TvShow.find_or_initialize_by(
        series_id: self.id,
        season: ep[:SeasonNumber],
        episode: ep[:EpisodeNumber]
      )

      show.reanalyzing_series = true
      show.title = self.title
      show.reset_status
      show.vote_count = ep[:RatingCount]
      show.vote_average = ep[:Rating]
      show.released_on = ep[:FirstAired]
      show.overview = ep[:Overview]
      show.episode_name = ep[:EpisodeName]

      result = show.save
    end
  end
end
