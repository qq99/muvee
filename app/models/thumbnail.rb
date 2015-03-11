#require 'phash/image' # temporarily disabled

class Thumbnail < ActiveRecord::Base
  belongs_to :video
  before_destroy :destroy_thumbnail_file
  after_create :postprocess_thumbnail

  IDEAL_NUMBER_OF_THUMBNAILS = 10
  THUMBNAIL_FOLDER = Rails.root.join('public', 'thumbnails')

  def url
    "/thumbnails/#{File.basename(raw_file_path)}"
  end

  def check_for_sbs_3d(opts = {})
    return false # temporarily disabled
    lhs = MiniMagick::Image.open(thumbnail_path)
    rhs = MiniMagick::Image.open(thumbnail_path)
    w = lhs[:width]
    h = lhs[:height]
    half_w = (w/2).to_i

    # http://www.imagemagick.org/script/command-line-processing.php#geometry
    lhs.crop "#{half_w}x#{h}+0+0"
    rhs.crop "#{half_w}x#{h}+#{half_w}+0"
    lhs_output = Rails.root.join("tmp", "lhs.jpg")
    rhs_output = Rails.root.join("tmp", "rhs.jpg")
    lhs.write lhs_output
    rhs.write rhs_output

    lhs_small = Rails.root.join("tmp", "lhs-small.jpg")
    rhs_small = Rails.root.join("tmp", "rhs-small.jpg")
    lhs.scale "10%x10%"
    rhs.scale "10%x10%"
    lhs.write lhs_small
    rhs.write rhs_small

    similarity = Phash::Image.new(lhs_small) % Phash::Image.new(rhs_small)
    if similarity > 0.8 # 3D
      if opts[:overwrite]
        result = MiniMagick::Image.open(lhs_output)
        result.scale "200%x100%"
        result.write scaled_path
        FileUtils.copy(scaled_path, thumbnail_path)
      end
      true
    else
      false
    end
  end

  private

  def postprocess_thumbnail
    if self.video.is_3d?
      self.check_for_sbs_3d(overwrite: true)
    end
  end

  def scaled_path
    Rails.root.join("tmp", "result.jpg")
  end

  def thumbnail_path
    THUMBNAIL_FOLDER.join(self.raw_file_path)
  end

  def destroy_thumbnail_file
    begin
      File.delete(thumbnail_path)
    rescue => e
      Rails.logger.info "Series#destroy_images: #{e}"
    end
  end
end
