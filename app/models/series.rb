class Series < ActiveRecord::Base
  has_many :genres_series
  has_many :genres, through: :genres_series

  has_many :people_series
  has_many :people, through: :people_series
  has_many :roles

  has_many :images
  has_many :backdrop_images
  has_many :poster_images

  def cast; roles.cast; end
  def crew; roles.crew; end
  def directors; roles.directors; end
  def producers; roles.directors; end

  validates :title, presence: true

  validates_uniqueness_of :title, allow_nil: false, allow_blank: false
  validates_uniqueness_of :tmdb_id, allow_nil: true, allow_blank: true

  POSTER_FOLDER = Rails.root.join('public', 'posters')
  FANART_FOLDER = Rails.root.join('public', 'fanart')
  BANNER_FOLDER = Rails.root.join('public', 'banners')

  has_many :tv_shows
  has_one :tvdb_series_result
  has_one :last_watched_video, class_name: "Video", primary_key: "last_watched_video_id", foreign_key: "id"

  scope :alphabetical, -> {order(title: :asc)}
  scope :remote, -> {where('has_local_episodes = false')}
  scope :local, -> {where('has_local_episodes = true')}
  scope :with_episodes, -> {where('tv_shows_count > 0')}
  scope :without_episodes, -> {where('tv_shows_count = 0')}
  scope :favorites, -> {where(is_favorite: true)}
  scope :paginated, ->(page, results_per_page) { limit(results_per_page).offset(page * results_per_page) }

  def poster_url
    return nil unless poster_images.present?
    poster_images.sort{|p| -p.vote_average}.first.url # TODO: use locale specific image
  end

  def backdrop_url
    return nil unless backdrop_images.present?
    backdrop_images.sort{|p| -p.vote_average}.first.url # TODO: use locale specific image
  end

  def find_tmdb_id
    TmdbSeriesSearchingService.new(title).run
  end

  def reanalyze(deep_reanalyze = false)
    if tmdb_id.blank?
      self.tmdb_id = find_tmdb_id
      self.save if tmdb_id.present?
    end

    return unless tmdb_id.present?

    TmdbSeriesMetadataService.new(tmdb_id).run

    return unless deep_reanalyze

    seasons_count.times do |i|
      SeasonReanalyzerWorker.perform_async(id, i+1)
    end

    people.map do |person|
      ReanalyzerWorker.perform_async("Person", person.id)
    end
  end

end
