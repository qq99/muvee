class TranscoderWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :transcode

  def perform(klass, input_path, transcode_path, eventual_path)
    klass = klass.constantize

    if File.exist?(eventual_path) # don't convert it again!
      Rails.logger.info "Video #{eventual_path} already transcoded; creating #{klass.to_s}, please review #{input_path}"
      klass.create(raw_file_path: eventual_path)
      return true
    end
    if File.exist?(transcode_path)
      Rails.logger.info "Video #{eventual_path} already present in #{transcode_path}; moving and creating, please review #{input_path}"
      move_transcoded_file(transcode_path, eventual_path)
      klass.create(raw_file_path: eventual_path)
      return true
    end

    # HEAVY WORK
    %x(#{transcode_to_webm_command(input_path, transcode_path)})

    sleep 10 # let the file handle close
    if File.exist? eventual_path
      Rails.logger.info "Video #{eventual_path} already transcoded; moving and creating, please review #{input_path}"
      move_transcoded_file(transcode_path, eventual_path)
      klass.create(raw_file_path: eventual_path)
      return true
    else
      raise "Conversion seems to have failed"
    end
  end

  def move_transcoded_file(transcode_path, eventual_path)
    FileUtils.copy(transcode_path, eventual_path)
    begin
      File.delete(transcode_path)
    rescue => e
      Rails.logger.info "TranscoderWorker: deleting transcoded file: #{e}"
    end
  end

  def transcode_to_webm_command(input_path, output_path)
    "avconv -i #{input_path.to_s.shellescape} -loglevel quiet -c:v libvpx -qmin 0 -qmax 50 -b:v 1M -c:a libvorbis -q:a 4 #{output_path.to_s.shellescape}"
  end
end
