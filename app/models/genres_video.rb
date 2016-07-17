class GenresVideo < ActiveRecord::Base
  belongs_to :video
  belongs_to :genre
  validates_uniqueness_of :genre_id, scope: :video_id, message: "already exists in the context of this video"
end
