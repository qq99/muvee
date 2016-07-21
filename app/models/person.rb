class Person < ActiveRecord::Base
  has_many :people_video, dependent: :destroy
  has_many :movies, -> { where(videos: {type: 'Movie'}) }, through: :people_video, source: :video
  has_many :tv_shows, -> { where(videos: {type: 'TvShow'}) }, through: :people_video, source: :video
  has_many :persons_series, dependent: :destroy
  has_many :series, through: :persons_series

  has_many :images, dependent: :destroy
  has_many :profile_images, dependent: :destroy

  has_many :roles, dependent: :destroy

  validates :full_name, presence: true, uniqueness: {case_sensitive: false}

  scope :alphabetical, -> {order(full_name: :asc)}
  scope :paginated, ->(page, results_per_page) { limit(results_per_page).offset(page * results_per_page) }

  def reanalyze(deep_reanalyze)
    TmdbPersonMetadataService.new(tmdb_id).run
  end

  def default_profile_picture
    return nil unless profile_images.present?
    profile_images.sample.url
  end

  def videos_and_series
    self.roles.map do |role|
      role.series || role.video
    end
  end
end
