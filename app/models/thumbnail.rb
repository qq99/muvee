class Thumbnail < ActiveRecord::Base
  belongs_to :video

  def url
    "/thumbnails/#{File.basename(raw_file_path)}"
  end
end
