class ActorsVideo < ActiveRecord::Base
  belongs_to :video
  belongs_to :actor
  validates_uniqueness_of :actor_id, scope: :video_id
end
