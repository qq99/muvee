class VideoCreationService

  def initialize(sources = {tv: [], movies: []})
    @sources = sources
  end

  def should_transcode?
    @config ||= ApplicationConfiguration.first
    @config.transcode_media
  end

  def transcode_folder
    @config ||= ApplicationConfiguration.first
    @config.transcode_folder
  end

  def generate
    new_tv_shows, failed_tv_shows = create_videos(TvShow, @sources[:tv])
    new_movies, failed_movies = create_videos(Movie, @sources[:movies])
    return [new_tv_shows, failed_tv_shows, new_movies, failed_movies]
  end

  def eligible_files(files)
    files.select{|file| Video::SERVABLE_FILETYPES.include? File.extname(file) }
  end

  def files_to_transcode(files)
    files.select{|file| Video::UNSERVABLE_FILETYPES.include? File.extname(file) }
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

    no_transcode.each do |filepath|
      if create_video(klass, filepath)
        successes << filepath
      else
        failures << filepath
      end
    end

    if should_transcode?
      needs_transcode.each do |path|
        filename = File.basename(path, File.extname(path))
        transcode_path = Pathname.new(transcode_folder).join("#{filename}.webm")
        transcode_and_create(klass, path, transcode_path.to_s, File.dirname(path) + "/#{filename}.webm")
      end
    end

    return [successes, failures]
  end

  def transcode_and_create(klass, input_path, transcode_path, eventual_path)
    TranscoderWorker.perform_async(klass, input_path, transcode_path, eventual_path)
  end

  def create_video(klass, filepath)
    video = klass.new(raw_file_path: filepath, status: 'local')
    return video.save
  end

end
