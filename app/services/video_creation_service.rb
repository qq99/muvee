class VideoCreationService
  include FolderFileLister

  def initialize(sources)
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
    @redis ||= Redis.new
    event = event.merge(type: 'VideoCreationService')
    @redis.publish(:sidekiq, event.to_json)
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

  def create_eligible_sources(klass, files)
    creation_size = files.size
    publish({status: "scanning", current: 0, max: creation_size})
    files.each_with_index do |filepath, i|
      publish({status: "scanning", current: i, max: creation_size, substatus: filepath})
      begin
        create_source(klass, filepath)
      rescue => e
        puts e
      end
    end
    publish({status: "complete", current: creation_size, max: creation_size, substatus: "Done!"})
  end

  def transcode_ineligible_sources(klass, files)
    return unless should_transcode?
    files.each do |filepath|
      create_transcode(klass, filepath)
    end
    TranscoderWorker.perform_async
  end

  def create_transcode(klass, filepath)
    return false if Transcode.exists?(raw_file_path: filepath)
    begin
      Transcode.create(type: "#{klass}Transcode", raw_file_path: filepath)
    rescue ActiveRecord::RecordNotUnique => e
      Rails.logger.info "Video/Transcode already existed, so transcode was not created: #{e}"
    end
  end

  def create_source(klass, filepath)
    return false if Source.exists?(raw_file_path: filepath)
    Source.create(type: "#{klass}Source", raw_file_path: filepath)
  end

end
