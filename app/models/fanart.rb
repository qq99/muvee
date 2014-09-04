class Fanart < ActiveRecord::Base
  include DownloadFile

  belongs_to :video
  before_create :download_image_file
  before_destroy :destroy_image_file

  FANART_FOLDER = Rails.root.join('public', 'fanart')

  attr_writer :remote_location

  def url
    "/fanart/#{File.basename(raw_file_path)}"
  end

  private

  def download_image_file
    return if @remote_location.blank?
    output_filename = UUID.generate(:compact) + File.extname(@remote_location)
    output_path = FANART_FOLDER.join(output_filename)
    if download_file(@remote_location, output_path)
      self.raw_file_path = output_path.to_s
    else
      false
    end
  end

  def fanart_path
    FANART_FOLDER.join(self.raw_file_path)
  end

  def destroy_image_file
    begin
      File.delete(fanart_path)
    rescue => e
      Rails.logger.info "Series#destroy_images: #{e}"
    end
  end
end
