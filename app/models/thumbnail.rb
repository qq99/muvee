class Thumbnail < ActiveRecord::Base
  belongs_to :video
  after_destroy :destroy_thumbnail_file

  def url
    "/thumbnails/#{File.basename(raw_file_path)}"
  end

  private

  def destroy_thumbnail_file
    File.delete(raw_file_path)
  end
end
