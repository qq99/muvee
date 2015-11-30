class GenresSeries < ActiveRecord::Base
  belongs_to :series
  belongs_to :genre
  validates_uniqueness_of :genre_id, scope: :series_id
end
