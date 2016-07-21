class Genre < ActiveRecord::Base
  include HasVideo
  include PrettyUrls
  pretty_url_by :name

  has_many :genres_videos
  has_videos(through: :genres_videos)
  has_many :genres_series
  has_many :series, through: :genres_series

  before_validation :sanitize_name
  validates :name,
    presence: true,
    uniqueness: {case_sensitive: false, message: '%{value} has already been taken in scope of genre'},
    on: :create

  SAME_THINGS = {
    "sci fi" => "Science Fiction",
    "scifi" => "Science Fiction",
    "sci-fi" => "Science Fiction"
  }.freeze

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
