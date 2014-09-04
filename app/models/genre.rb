class Genre < ActiveRecord::Base
  has_and_belongs_to_many :videos

  before_validation :sanitize_name
  validates :name, presence: true, uniqueness: {case_sensitive: false}

  SAME_THINGS = {
    "sci fi" => "Science Fiction"
  }.freeze

  def sanitize_name
    self.name = name.strip.titleize
    SAME_THINGS.each do |key, val|
      self.name = val if name.downcase == key
    end
  end
end
