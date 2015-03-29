class VideoCreationService

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

  def create_tv_shows

  end

  def eligible_files(files)
    files.select{|file| Video::SERVABLE_CONTAINERS.include? File.extname(file) }
  end

  def files_to_transcode(files)
    files.select{|file| Video::UNSERVABLE_CONTAINERS.include? File.extname(file) }
  end

  def publish(event)
    @redis ||= Redis.new
    event = event.merge(type: 'VideoCreationService')
    @redis.publish(:sidekiq, event.to_json)
  end

  def get_files_in_folders(folders)
    files = []
    folders.each do |folder|
      folder << "/" if folder[-1] != "/" # append trailing slash if not present
      all_files_in_folder = Dir["#{folder}**/*.*"]
      files.push(*all_files_in_folder)
    end
    files
  end

  def create_videos(klass, folders)
    files = get_files_in_folders(folders)

    create_eligible_sources(klass, eligible_files(files))
    transcode_ineligible_sources(klass, files_to_transcode(files))
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
    files.each do |path|
      TranscoderWorker.perform_async(klass, path)
    end
  end

  def create_source(klass, filepath)
    return false if Source.exists?(raw_file_path: filepath)
    source = Source.new(type: "#{klass}Source", raw_file_path: filepath)
    source.save
  end

end
