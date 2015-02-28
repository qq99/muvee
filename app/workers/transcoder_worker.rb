class TranscoderWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :transcode

  def transcode_folder
    @config ||= ApplicationConfiguration.first
    @config.transcode_folder
  end

  def publish(event)
    redis = Redis.new
    event = event.merge(type: 'TranscoderWorker')
    redis.publish(:sidekiq, event.to_json)
  end

  def perform(klass, input_path)
    klass = klass.constantize

    filename = File.basename(input_path, File.extname(input_path))
    transcode_path = Pathname.new(transcode_folder).join(filename).to_s
    eventual_path = File.dirname(input_path) + "/#{filename}"

    #return if Sidekiq::Queue.new("transcode").to_a.length > 0
    webm_path = eventual_path + ".webm"

    if Video::SERVABLE_MP4_VIDEO_CODECS.include?(Video.get_video_encoding(input_path))
      transcode_path = transcode_path + ".mp4"
      eventual_path = eventual_path + ".mp4"
      video_codec = "copy"
      if Video::SERVABLE_MP4_AUDIO_CODECS.include?(Video.get_audio_encoding(input_path))
        audio_codec = "copy"
      else
        audio_codec = "libvorbis"
      end
    else
      transcode_path = transcode_path + ".webm"
      eventual_path = eventual_path + ".webm"
      video_codec = "libvpx"
      audio_codec = "libvorbis"

      if Video::SERVABLE_WEBM_AUDIO_CODECS.include?(Video.get_audio_encoding(input_path))
        audio_codec = "copy"
      else
        audio_codec = "libvorbis"
      end
    end


    if File.exist?(eventual_path) || File.exist?(webm_path) # don't convert it again! webm stuff is legacy and should be removed!
      notice = "Video #{eventual_path} already transcoded; creating #{klass.to_s}, please review #{input_path}"
      publish({notice: notice})
      Rails.logger.info notice
      klass.create(raw_file_path: eventual_path)
      return true
    end
    if File.exist?(transcode_path) # in process
      notice = "Video #{eventual_path} already present in #{transcode_path}; please review"
      publish({notice: notice})
      Rails.logger.info notice
      return true
    end

    # HEAVY WORK
    publish({notice: "Transcoding #{input_path}"})

    cmd = transcode_specify_codec_command(input_path, transcode_path, video_codec, audio_codec)
    Rails.logger.info "Transcoding #{input_path} with #{cmd}"
    success = system("#{cmd}")

    sleep 10 # let the file handle close
    if success
      Rails.logger.info "Video #{eventual_path} already transcoded; moving and creating, please review #{input_path}"
      move_transcoded_file(transcode_path, eventual_path)
      sleep 5 # let the file handle close (?)
      klass.create(raw_file_path: eventual_path)
      return true
    else
      File.delete(transcode_path) if File.exist?(transcode_path) # clean up
      puts "Conversion seems to have failed: #{success}"
      Rails.logger.error "Conversion seems to have failed"
      return false
    end
  end

  def move_transcoded_file(transcode_path, eventual_path)
    begin
      FileUtils.mv(transcode_path, eventual_path)
    rescue => e
      Rails.logger.info "TranscoderWorker: moving file #{transcode_path} to #{eventual_path}: #{e}"
    end
  end

  def transcode_specify_codec_command(input_path, output_path, video_codec, audio_codec)
    video_params = if video_codec != "copy"
      " -qmin 0 -qmax 50 -b:v 1M"
    else
      ""
    end

    audio_params = if audio_codec != "copy"
      " -q:a 4"
    else
      ""
    end

    "avconv -threads auto -i #{input_path.to_s.shellescape} -loglevel quiet -c:v #{video_codec}#{video_params} -c:a #{audio_codec}#{audio_params} #{output_path.to_s.shellescape}"
  end
end
