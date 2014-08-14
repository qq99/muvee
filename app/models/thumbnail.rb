class Thumbnail < ActiveRecord::Base
  belongs_to :video
  before_destroy :destroy_thumbnail_file

  THUMBNAIL_FOLDER = Rails.root.join('public', 'thumbnails')

  def url
    "/thumbnails/#{File.basename(raw_file_path)}"
  end

  private

  def destroy_thumbnail_file
    begin
      File.delete(THUMBNAIL_FOLDER.join(raw_file_path))
    rescue Exception => e
      Rails.logger.info "Series#destroy_images: #{e}"
    end
  end
end
