class Genre < ActiveRecord::Base
  include HasVideo

  has_many :genres_videos
  has_videos(through: :genres_videos)

  before_validation :sanitize_name
  validates :name, presence: true, uniqueness: {case_sensitive: false}

  SAME_THINGS = {
    "sci fi" => "Science Fiction",
    "scifi" => "Science Fiction"
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
