class Transcode < ActiveRecord::Base
  include AssociatesSelfWithVideo
  include HasMetadata
  before_validation :associate_self_with_video, on: :create
  belongs_to :video

  scope :complete, -> {where(status: 'complete')}
  scope :incomplete, -> {where.not(status: 'complete')}
  scope :not_working, -> {where.not(status: 'transcoding')}
  scope :ready, -> {where.not(status: 'transcoding').where.not(status: 'complete').where.not(status: 'started')}

  def config
    @config ||= ApplicationConfiguration.first
  end

  def transcode_folder
    config.transcode_folder
  end

  def transcode_parameters
    return @optimal_transcoding_parameters if @optimal_transcoding_parameters.present?

    current_video_encoding = Video.get_video_encoding(raw_file_path)
    current_audio_encoding = Video.get_audio_encoding(raw_file_path)
    container, video_codec, audio_codec = nil

    if Video::SERVABLE_MP4_VIDEO_CODECS.include?(current_video_encoding)
      container   = '.mp4'
      video_codec = 'copy'
      audio_codec = if Video::SERVABLE_MP4_AUDIO_CODECS.include?(current_audio_encoding)
        'copy'
      else
        'libvorbis'
      end
    elsif Video::SERVABLE_WEBM_VIDEO_CODECS.include?(current_video_encoding)
      container   = '.webm'
      video_codec = 'copy'
      audio_codec = if Video::SERVABLE_WEBM_AUDIO_CODECS.include?(current_audio_encoding)
        'copy'
      else
        'libvorbis'
      end
    else # default case
      container   = '.webm'
      video_codec = 'libvpx'
      audio_codec = if Video::SERVABLE_WEBM_AUDIO_CODECS.include?(current_audio_encoding)
        'copy'
      else
        'libvorbis'
      end
    end

    @optimal_transcoding_parameters = {
      container: container,
      video_codec: video_codec,
      audio_codec: audio_codec
    }
  end

  def filename # /foo/bar/baz.mp4 => baz
    File.basename(raw_file_path, File.extname(raw_file_path))
  end

  def source_klass # TvShowSource, MovieSource
    "#{video.class.name}Source"
  end

  def transcode_path # /tmp/transcoding/foo
    Pathname.new(transcode_folder).join("#{filename}.muv-transcoding#{transcode_parameters[:container]}").to_s
  end

  def eventual_path
    "#{File.dirname(raw_file_path)}/#{filename}.muv-transcoded#{transcode_parameters[:container]}"
  end

  def started?
    status == 'started'
  end

  def transcoding?
    status == 'transcoding'
  end

  def complete?
    status == 'complete'
  end

  def failed?
    status == 'failed'
  end

  def pending?
    status == 'pending'
  end

  def transcoded_file_exists?
    File.exist?(eventual_path)
  end

  def transcoding_file_exists?
    File.exist?(transcode_path)
  end

  def transcode
    return false if started?
    if complete? # don't convert it again!
      move_transcoded_file! if transcoding_file_exists?
      note "#{eventual_path} already transcoded; please review #{raw_file_path}"
      return true
    end
    if transcoding? # don't start converting it again!
      note "Transcode #{id} already in progress, pre-empting"
      return true
    end

    if (pending? || failed?) && transcoding_file_exists? # clean up, just in case the ensure someone didn't get called
      self.update_attribute(:status, 'started')
      delete_transcoding_file!
    end

    perform

    if complete?
      sleep 10 # let the file handle close (?)
      move_transcoded_file!
      sleep 5 # let the file handle close (?)
      return true
    end

    false
  ensure
    unless complete? || transcoding?
      self.update_attribute(:status, 'failed')
      delete_transcoding_file!
    end
  end

  def delete_transcoding_file!
    return unless transcoding_file_exists?
    note "Deleting failed transcode file #{transcode_path}"
    File.delete(transcode_path)
    sleep 2
  end

  def move_transcoded_file!
    unless transcoding_file_exists?
      note "Attempted to move non-existant file #{transcode_path} to #{eventual_path}"
      return false
    end
    begin
      success = FileUtils.mv(transcode_path, eventual_path)
      if success
        note "Succeeded in moving file #{transcode_path} to #{eventual_path}"
        return success
      end
    rescue => e
      note "Failed to move file #{transcode_path} to #{eventual_path}: #{e}"
      return false
    end
  end

  def transcode_command
    video_params = " -qmin 0 -qmax 50 -b:v 1M" if transcode_parameters[:video_codec] != "copy"
    audio_params = " -q:a 4" if transcode_parameters[:audio_codec] != "copy"

    "avconv -threads auto -i #{raw_file_path.to_s.shellescape} -loglevel quiet -c:v #{transcode_parameters[:video_codec]}#{video_params} -c:a #{transcode_parameters[:audio_codec]}#{audio_params} #{transcode_path.to_s.shellescape}"
  end

  def note(note)
    note = "Transcode.id=#{id}:: #{note}"
    Rails.logger.info note
    # puts note
  end

  private

  def perform_transcode_subprocess
    system(transcode_command)
  end

  def perform
    self.update_attribute(:status, 'transcoding')
    note "Transcoding #{raw_file_path} with #{transcode_command}"
    success = perform_transcode_subprocess
    self.update_attribute(:status, 'complete') if success
  ensure
    unless complete?
      self.update_attribute(:status, 'failed')
      note "Conversion.id=#{id} seems to have failed: #{success}"
    end
  end

end
