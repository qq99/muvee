class Image < ActiveRecord::Base
  belongs_to :video
  belongs_to :series

  def url
    "http://image.tmdb.org/t/p/original#{path}"
  end
end
