class Image < ActiveRecord::Base
  belongs_to :video
  belongs_to :series
end
