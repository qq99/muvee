class Role < ActiveRecord::Base
  belongs_to :person
  belongs_to :video

  scope :directors, -> { where(department: 'Directing') }
  scope :producers, -> { where(department: 'Production') }
  scope :cast, -> { where(department: 'Performance') }
  scope :crew, -> { where.not(department: 'Performance') }

  def full_name
    person.full_name
  end
end
