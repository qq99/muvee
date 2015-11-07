class GenresSeries < ActiveRecord::Base
  belongs_to :serie
  belongs_to :genre
  validates_uniqueness_of :genre_id, scope: :series_id
end
