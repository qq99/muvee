class VideoCreationService
  include FolderFileLister

  def initialize(sources: {})
    default = {tv: [], movies: []}
    sources = default.merge!(sources)
    @sources = sources
  end

  def should_transcode?
    ApplicationConfiguration.first.transcode_media
  end

  def generate
    new_tv_shows, failed_tv_shows = create_videos(TvShow, @sources[:tv])
    new_movies, failed_movies = create_videos(Movie, @sources[:movies])
    return [new_tv_shows, failed_tv_shows, new_movies, failed_movies]
  end

  def publish(event)
    event[:namespace] = 'VideoCreationService'
    ActionCable.server.broadcast "progress_reports", event
  end

  def create_videos(klass, folders)
    files = get_files_in_folders(folders)

    files.reject! do |file|
      !Video::VIDEO_CONTAINERS.include?(File.extname(file)) ||
      file.downcase.include?("sample")
    end

    unsourced_files = files.select do |file|
      !Source.exists?(raw_file_path: file)
    end

    grouped = {
      to_transcode: [],
      to_source: []
    }

    grouped = unsourced_files.inject(grouped) do |hash, filename|
      if Video.needs_transcoding?(filename)
        hash[:to_transcode] << filename
      else
        hash[:to_source] << filename
      end
      hash
    end

    create_eligible_sources(klass, grouped[:to_source])
    transcode_ineligible_sources(klass, grouped[:to_transcode])
  end

  # for existing videos, e.g., when Torrent completes, it already knows the Video to link the source to
  def create_source_for_video(video:, raw_file_path:)
    return if Source.exists?(raw_file_path: raw_file_path)

    if Video.needs_transcoding?(raw_file_path)
      create_transcode(video: video, type: "#{video.type}Transcode", raw_file_path: raw_file_path)
    else
      create_source(video: video, type: "#{video.type}Source", raw_file_path: raw_file_path)
    end
  end

  def create_eligible_sources(klass, files)
    creation_size = files.size
    publish({status: "scanning", current: 0, max: creation_size})
    files.each_with_index do |filepath, i|
      publish({status: "scanning", current: i, max: creation_size, substatus: filepath})
      begin
        create_source(type: "#{klass}Source", raw_file_path: filepath)
      rescue => e
        puts e
      end
    end
    publish({status: "complete", current: creation_size, max: creation_size, substatus: "Done!"})
  end

  def transcode_ineligible_sources(klass, files)
    return unless should_transcode?
    files.each do |filepath|
      create_transcode(type: "#{klass}Transcode", raw_file_path: filepath)
    end
  end

  def create_transcode(opts)
    return false if Transcode.exists?(opts[:raw_file_path])
    begin
      Transcode.create(opts)
    rescue ActiveRecord::RecordNotUnique => e
      Rails.logger.info "Video/Transcode already existed, so transcode was not created: #{e}"
    end
  end

  def create_source(opts)
    return false if Source.exists?(raw_file_path: opts[:raw_file_path])
    SourceCreationWorker.perform_async(
      opts[:type],
      opts[:raw_file_path],
      opts[:video].try(:id)
    )
  end

end
