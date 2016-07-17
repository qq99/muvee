class PeopleVideo < ActiveRecord::Base
  belongs_to :video
  belongs_to :person
  validates_uniqueness_of :person_id, scope: :video_id, message: "already exists in the context of this video"
end
