class Video < ActiveRecord::Base
  has_many :thumbnails
  before_create :shellout_and_grab_duration

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

  private

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
end
