class Genre < ActiveRecord::Base
  has_and_belongs_to_many :videos

  validates_uniqueness_of :name, allow_blank: false

  before_create :titleize_name

  def titleize_name
    self.name = name.titleize
  end
end
