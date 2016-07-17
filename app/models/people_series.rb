class PeopleSeries < ActiveRecord::Base
  belongs_to :series
  belongs_to :person
  validates_uniqueness_of :person_id, scope: :series_id
end
