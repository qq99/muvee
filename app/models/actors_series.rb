class ActorsSeries < ActiveRecord::Base
  belongs_to :serie
  belongs_to :actor
  validates_uniqueness_of :actor_id, scope: :series_id
end
