class Thumbnail < ActiveRecord::Base
  belongs_to :video
  before_destroy :destroy_thumbnail_file

  THUMBNAIL_FOLDER = Rails.root.join('public', 'thumbnails')

  def url
    "/thumbnails/#{File.basename(raw_file_path)}"
  end

  # valid options:
  # - overwrite
  def check_for_sbs_3d(opts = {})
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

    diff_file = Rails.root.join("tmp", "diff.jpg")
    result = %x{compare -metric RMSE #{lhs_output} #{rhs_output} #{diff_file} 2>&1}

    results = result.gsub(/[\(\)]/i, '').split(" ").map(&:to_f)
    if results[1] > 0.10 # not 3D
      false
    else
      result = MiniMagick::Image.open(lhs_output)
      result.scale "200%x100%"
      result.write scaled_path
      if opts[:overwrite]
        File.copy(scaled_path, thumbnail_path)
      end
      true
    end
  end

  private

  def scaled_path
    Rails.root.join("tmp", "result.jpg")
  end

  def thumbnail_path
    THUMBNAIL_FOLDER.join(self.raw_file_path)
  end

  def destroy_thumbnail_file
    begin
      File.delete(thumbnail_path)
    rescue Exception => e
      Rails.logger.info "Series#destroy_images: #{e}"
    end
  end
end
