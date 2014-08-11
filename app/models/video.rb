class Video < ActiveRecord::Base
  has_many :thumbnails
  before_create :shellout_and_grab_duration

  THUMBNAIL_PATH = "/public/thumbnails/"

  def determine_video_duration_in_seconds

  end

  def filename_no_extension
    return "" if raw_file_path.empty?

    @filename_no_extension ||= File.basename(raw_file_path, File.extname(raw_file_path))
  end

  def pretty_title(str)
    str.gsub!(/(x264|hdtv)/i, '')
    str.gsub(/[\.\_\-]/, ' ').titleize.squish.strip
  end

  def create_thumbnail(at_seconds)
    thumb_path = new_thumbnail_path
    shellout_and_grab_thumbnail(at_seconds, thumb_path)
    #TODO validate this worked
    self.thumbnails.create(raw_file_path: thumb_path)
  end

  def new_thumbnail_path
    Dir.getwd() + THUMBNAIL_PATH + UUID.generate(:compact) + ".jpg"
  end

  private

  def avconv_create_thumbnail_command(at_seconds, output_path)
    "avconv -ss " + at_seconds.to_s.shellescape + " -i " + raw_file_path.shellescape + " -qscale 1 -vsync 1 -vframes 1 -y " + output_path.shellescape
  end

  def avprobe_grab_duration_command
    "avprobe " + raw_file_path.shellescape + " 2>&1 | grep -Eo 'Duration: [0-9:.]*' | cut -c 11-"
  end

  def shellout_and_grab_duration
    result = %x(#{avprobe_grab_duration_command})
    if result.present? && result.length > 0
      hours, minutes, seconds = result.split(":")
      self.duration = hours.to_i*60*60 + minutes.to_i*60 + seconds.to_i
    else
      self.duration = 0
    end
  end

  def shellout_and_grab_thumbnail(at_seconds, output_path)
    return if self.duration == 0
    Kernel.system(avconv_create_thumbnail_command(at_seconds, output_path))
  end
end
