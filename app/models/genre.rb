class Genre < ActiveRecord::Base
  has_many :genres_videos
  has_many :videos, through: :genres_videos
  has_many :movies, -> { where(videos: {type: 'Movie'}) }, through: :genres_videos, source: :video
  has_many :tv_shows, -> { where(videos: {type: 'TvShow'}) }, through: :genres_videos, source: :video

  before_validation :sanitize_name
  validates :name, presence: true, uniqueness: {case_sensitive: false}

  SAME_THINGS = {
    "sci fi" => "Science Fiction",
    "scifi" => "Science Fiction"
  }.freeze

  def has_movies?
    movies.count > 0
  end

  def has_local_movies?
    movies.local.count > 0
  end

  def has_tv_shows?
    tv_shows.count > 0
  end

  def self.normalized_name(name)
    name = name.strip.titleize
    SAME_THINGS.each do |key, val|
      name = val if name.downcase == key
    end
    name
  end

  def sanitize_name
    self.name = Genre.normalized_name(name)
  end
end
