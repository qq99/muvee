class Video < ActiveRecord::Base
  has_many :thumbnails, dependent: :destroy
  has_many :fanarts, dependent: :destroy

  has_many :genres_videos
  has_many :genres, through: :genres_videos

  has_many :torrents

  validates_uniqueness_of :raw_file_path, allow_nil: true, allow_blank: true
  validates_uniqueness_of :imdb_id, allow_nil: true, allow_blank: true, if: Proc.new { |video| video.status == "remote" }
  after_create :shellout_and_grab_duration
  after_create :create_initial_thumb

  scope :local, -> {where(status: 'local')}
  scope :remote, -> {where(status: 'remote')}
  scope :downloading, -> {where(status: 'downloading')}
  scope :local_and_downloading, -> {where('status in (?)', ['local', 'downloading'])}
  scope :movies, -> {where(type: "Movie")}
  scope :tv_shows, -> {where(type: "TvShow")}
  scope :unwatched, -> {where(left_off_at: nil)}
  scope :newest, -> {order(created_at: :desc)}

  # https://developer.mozilla.org/en-US/docs/Web/HTML/Supported_media_formats
  SERVABLE_CONTAINERS = %w{.m4v .mp4 .webm}.freeze
  UNSERVABLE_CONTAINERS = %w{.avi .mkv}.freeze

  SERVABLE_MP4_VIDEO_CODECS = %w{h264}.freeze
  SERVABLE_MP4_AUDIO_CODECS = %w{libvorbis mp3 mpeg3 aac}.freeze
  SERVABLE_WEBM_VIDEO_CODECS = %w{libvpx vp8 vorbis}.freeze # may not be the proper names of said codecs as returned by avprobe
  SERVABLE_WEBM_AUDIO_CODECS = %w{libvorbis}.freeze

  QUALITIES = /(1080p|720p)/i

  # convert to webm:
  # http://superuser.com/questions/556463/converting-video-to-webm-with-ffmpeg-avconv
  # avconv -i src.avi -c:v libvpx -qmin 0 -qmax 50 -b:v 1M -c:a libvorbis -q:a 4 output2.webm

  def local?
    status == 'local'
  end

  def remote?
    status == 'remote'
  end

  def downloading?
    status == 'downloading'
  end

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
    self.thumbnails.count == Thumbnail::IDEAL_NUMBER_OF_THUMBNAILS
  end

  def self.thumbnail_root_path
    "/public/thumbnails/"
  end

  def file_not_yet_present?
    raw_file_path.blank?
  end

  def filename_no_extension
    return "" if file_not_yet_present?

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
    str.gsub!(/(x264|hdtv|x264-2HD)/i, '')
    str.gsub(/[\.\_\-]/, ' ').titleize.squish.strip
  end

  def create_initial_thumb
    return if file_not_yet_present?
    return if self.duration == 0

    create_thumbnail (self.duration / 2).to_i
  end

  def create_n_thumbnails(n_thumbnails) # evenly spaced out throughout the video
    return if file_not_yet_present?
    return if self.duration == 0

    spacing = self.duration / (n_thumbnails + 2).to_f

    n_thumbnails.times do |i|
      at_second = spacing + (i*spacing).to_i
      create_thumbnail(at_second)
    end
  end

  def create_thumbnail(at_seconds)
    return if file_not_yet_present?

    thumb_path = new_thumbnail_path
    success = shellout_and_grab_thumbnail(at_seconds, thumb_path)
    if success
      thumb = self.thumbnails.create(raw_file_path: thumb_path)
      if self.is_3d?
        thumb.check_for_sbs_3d(overwrite: true)
        # thumb.check_for_tab_3d
      end
    else
      Rails.logger.error "Failed to create thumbnail for Video.id=#{id}"
    end
  end

  def new_thumbnail_path
    Dir.getwd() + Video.thumbnail_root_path + UUID.generate(:compact) + ".jpg"
  end

  def reanalyze
    shellout_and_grab_duration if duration.blank? || duration == 0
    create_initial_thumb if thumbnails.blank?
  end
  def redownload_missing; end
  def redownload; end

  def delete_file!
    File.delete(raw_file_path)
  end

  def compute_genres(genre_string)
    genre_array = genre_string.split(/,|\|/)
    dedupe_genre_array(genre_array)
  end

  def dedupe_genre_array(genre_array)
    genre_array.compact.map(&:strip).map(&:titleize).uniq.reject(&:blank?)
  end

  def avconv_create_thumbnail_command(at_seconds, output_path)
    "avconv -loglevel quiet -ss " + at_seconds.to_s.shellescape + " -i " + raw_file_path.shellescape + " -qscale 1 -vsync 1 -vframes 1 -y " + output_path.shellescape
  end

  def avprobe_grab_duration_command
    "avprobe " + raw_file_path.shellescape + " 2>&1 | grep -Eo 'Duration: [0-9:.]*' | cut -c 11-"
  end

  def video_encoding
    self.class.get_video_encoding(raw_file_path)
  end

  def self.get_video_encoding(path)
    command = "avprobe " + path.shellescape + " 2>&1 | grep -Eo 'Video: [a-zA-Z0-9]*' | cut -c 8-"
    result = %x(#{command})
    type = result.strip.downcase
    type
  end

  def audio_encoding
    self.class.get_audio_encoding(raw_file_path)
  end

  def self.get_audio_encoding(path)
    command = "avprobe " + path.shellescape + " 2>&1 | grep -Eo 'Audio: [a-zA-Z0-9]*' | cut -c 8-"
    result = %x(#{command})
    type = result.strip.downcase
    type
  end

  def shellout_and_grab_duration
    return if file_not_yet_present?
    result = %x(#{avprobe_grab_duration_command})
    if result.present? && result.length > 0
      hours, minutes, seconds = result.split(":")
      self.duration = hours.to_i*60*60 + minutes.to_i*60 + seconds.to_i
    else
      self.duration = 0
    end
  end

  def shellout_and_grab_thumbnail(at_seconds, output_path)
    return if file_not_yet_present?
    return if self.duration == 0
    system(avconv_create_thumbnail_command(at_seconds, output_path))
  end

  def move_raw_file(new_path)
    self.update_attribute(:raw_file_path, new_path)
    FileUtils.mv(raw_file_path, new_path)
  end
end
