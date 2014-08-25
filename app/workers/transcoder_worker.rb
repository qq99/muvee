class TranscoderWorker
  include Sidekiq::Worker

  def perform(klass, input_path, transcode_path, eventual_path)
    if File.exist?(eventual_path) # don't convert it again!
      Video.create(raw_file_path: eventual_path)
      return true
    end
    if File.exist?(transcode_path)
      move_transcoded_file(transcode_path, eventual_path)
      Video.create(raw_file_path: eventual_path)
      return true
    end

    # HEAVY WORK
    %x(#{transcode_to_webm_command(input_path, transcode_path)})

    if File.exist? eventual_path
      move_transcoded_file(transcode_path, eventual_path)
      Video.create(raw_file_path: eventual_path)
      return true
    else
      raise "Conversion seems to have failed"
    end
  end

  def move_transcoded_file(transcode_path, eventual_path)
    FileUtils.copy(transcode_path, eventual_path)
    begin
      File.delete(transcode_path)
    rescue Exception => e
      Rails.logger.info "TranscoderWorker: deleting transcoded file: #{e}"
    end
  end

  def transcode_to_webm_command(input_path, output_path)
    "avconv -i #{input_path.to_s.shellescape} -c:v libvpx -qmin 0 -qmax 50 -b:v 1M -c:a libvorbis -q:a 4 #{output_path.to_s.shellescape}"
  end
end
