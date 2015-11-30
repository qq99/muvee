class ActorsSeries < ActiveRecord::Base
  belongs_to :series
  belongs_to :actor
  validates_uniqueness_of :actor_id, scope: :series_id
end
