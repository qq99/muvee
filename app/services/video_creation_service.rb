class VideoCreationService

  def initialize(sources)
    default = {tv: [], movies: []}
    sources = default.merge!(sources)
    @sources = sources
  end

  def should_transcode?
    @config ||= APP_CONFIG
    @config.transcode_media
  end

  def generate
    new_tv_shows, failed_tv_shows = create_videos(TvShow, @sources[:tv])
    new_movies, failed_movies = create_videos(Movie, @sources[:movies])
    return [new_tv_shows, failed_tv_shows, new_movies, failed_movies]
  end

  def eligible_files(files)
    files.select{|file| Video::SERVABLE_CONTAINERS.include? File.extname(file) }
  end

  def files_to_transcode(files)
    files.select{|file| Video::UNSERVABLE_CONTAINERS.include? File.extname(file) }
  end

  def publish(event)
    redis = Redis.new
    event = event.merge(type: 'VideoCreationService')
    redis.publish(:sidekiq, event.to_json)
  end

  def create_videos(klass, folders)
    files = []
    successes = []
    failures = []

    folders.each do |folder|
      folder = "#{folder}/" if folder[-1] != "/" # append trailing slash if not there
      all_files_in_folder = Dir["#{folder}**/*.*"]
      files.push(*all_files_in_folder)
    end
    no_transcode = eligible_files(files) # filter out non-acceptable formats
    needs_transcode = files_to_transcode(files)

    creation_size = no_transcode.size
    publish({status: "scanning", current: 0, max: creation_size})
    no_transcode.each_with_index do |filepath, i|
      publish({status: "scanning", current: i, max: creation_size, substatus: filepath})
      begin
        if create_video(klass, filepath)
          successes << filepath
        else
          failures << filepath
        end
      rescue
        failures << filepath
      end
    end
    publish({status: "complete", current: creation_size, max: creation_size, substatus: "Done!"})

    if should_transcode?
      needs_transcode.each do |path|
        TranscoderWorker.perform_async(klass, path)
      end
    end

    return [successes, failures]
  end

  def create_video(klass, filepath)
    video = klass.new(raw_file_path: filepath, status: 'local')
    return video.save
  end

end
