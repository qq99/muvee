class Genre < ActiveRecord::Base
  has_and_belongs_to_many :videos

  validates :name, presence: true, uniqueness: {case_sensitive: false}

  before_create :sanitize_name

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
