class Video < ActiveRecord::Base
  has_many :thumbnails, dependent: :destroy
  validates_uniqueness_of :raw_file_path
  after_create :shellout_and_grab_duration
  after_create :create_initial_thumb

  scope :latest, -> {order(season: :desc, episode: :desc)}
  scope :release_order, -> {order(season: :asc, episode: :asc)}
  scope :unwatched, -> {where(left_off_at: nil)}

  # https://developer.mozilla.org/en-US/docs/Web/HTML/Supported_media_formats
  SERVABLE_FILETYPES = %w{.m4v .mp4 .webm}.freeze
  UNSERVABLE_FILETYPES = %w{.avi .mkv}.freeze
  QUALITIES = /(1080p|720p)/i

  # convert to webm:
  # http://superuser.com/questions/556463/converting-video-to-webm-with-ffmpeg-avconv
  # avconv -i src.avi -c:v libvpx -qmin 0 -qmax 50 -b:v 1M -c:a libvorbis -q:a 4 output2.webm

  def is_3d?
    is_3d.present?
  end

  def is_tv?
    type == "TvShow"
  end

  def is_movie?
    type == "Movie"
  end

  def has_set_of_thumbnails?
    self.thumbnails.length > 1
  end

  def self.thumbnail_root_path
    "/public/thumbnails/"
  end

  def filename_no_extension
    return "" if raw_file_path.empty?

    @filename_no_extension ||= File.basename(raw_file_path, File.extname(raw_file_path))
  end

  def filename_without_quality(filename)
    matches = Video::QUALITIES.match(filename)
    if matches.present?
      quality = matches[0]
      remaining_filename = filename.gsub(Video::QUALITIES, "")
    else
      quality = nil
      remaining_filename = filename
    end
    [quality, remaining_filename]
  end

  def left_off_at_percent
    return 0 if !self.left_off_at
    (self.left_off_at.to_f / self.duration.to_f) * 100
  end

  def pretty_title(str)
    str.gsub!(/(x264|hdtv)/i, '')
    str.gsub(/[\.\_\-]/, ' ').titleize.squish.strip
  end

  def create_initial_thumb
    return if self.duration == 0

    create_thumbnail (self.duration / 2).to_i
  end

  def create_n_thumbnails(n_thumbnails) # evenly spaced out throughout the video
    return if self.duration == 0

    spacing = self.duration / (n_thumbnails + 2).to_f

    n_thumbnails.times do |i|
      at_second = spacing + (i*spacing).to_i
      create_thumbnail(at_second)
    end
  end

  def create_thumbnail(at_seconds)
    thumb_path = new_thumbnail_path
    shellout_and_grab_thumbnail(at_seconds, thumb_path)
    #TODO validate this worked
    thumb = self.thumbnails.create(raw_file_path: thumb_path)
    if self.is_3d?
      thumb.check_for_sbs_3d(overwrite: true)
      # thumb.check_for_tab_3d
    end
  end

  def new_thumbnail_path
    Dir.getwd() + Video.thumbnail_root_path + UUID.generate(:compact) + ".jpg"
  end

  private

  def avconv_create_thumbnail_command(at_seconds, output_path)
    "avconv -loglevel quiet -ss " + at_seconds.to_s.shellescape + " -i " + raw_file_path.shellescape + " -qscale 1 -vsync 1 -vframes 1 -y " + output_path.shellescape
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
    %x(#{avconv_create_thumbnail_command(at_seconds, output_path)})
  end
end
