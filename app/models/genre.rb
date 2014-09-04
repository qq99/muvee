class Genre < ActiveRecord::Base
  has_and_belongs_to_many :videos

  validates_uniqueness_of :name, allow_blank: false

  before_create :sanitize_name

  def sanitize_name
    self.name = name.strip.titleize
  end
end
