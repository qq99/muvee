class Video < ActiveRecord::Base
  has_many :thumbnails

  def pretty_title(str)
    str.gsub!(/(x264|hdtv)/i, '')
    str.gsub(/[\.\_\-]/, ' ').titleize.squish.strip
  end
end
