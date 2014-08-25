class VideoCreationService

  def initialize(sources = {tv: [], movies: []})
    @sources = sources
  end

  def generate
    new_tv_shows, failed_tv_shows = create_tv_shows(@sources[:tv])
    new_movies, failed_movies = create_movies(@sources[:movies])
    return [new_tv_shows, failed_tv_shows, new_movies, failed_movies]
  end

  def eligible_files(files)
    files.select{|file| Video::SERVABLE_FILETYPES.include? File.extname(file) }
  end

  def files_to_transcode(files)
    files.select{|file| Video::UNSERVABLE_FILETYPES.include? File.extname(file) }
  end

  def create_movies(folders)
    files = []
    folders.each do |folder|
      folder = "#{folder}/" if folder[-1] != "/" # append trailing slash if not there
      all_files_in_folder = Dir["#{folder}**/*.*"]
      files.push(*all_files_in_folder)
    end
    files = eligible_files(files) # filter out non-acceptable formats

    successes = []
    failures = []
    files.each do |filepath|
      video = Movie.new(raw_file_path: filepath)
      if video.save
        successes << video
      else
        failures << video
      end
    end

    return [successes, failures]
  end

  def create_tv_shows(folders)
    files = []
    folders.each do |folder|
      folder = "#{folder}/" if folder[-1] != "/" # append trailing slash if not there
      all_files_in_folder = Dir["#{folder}**/*.*"]
      files.push(*all_files_in_folder)
    end
    no_transcode = eligible_files(files) # filter out non-acceptable formats
    needs_transcode = files_to_transcode(files)

    successes = []
    failures = []
    # no_transcode.each do |filepath|
    #   video = TvShow.new(raw_file_path: filepath)
    #   if video.save
    #     successes << video
    #   else
    #     failures << video
    #   end
    # end

    needs_transcode.each do |path|
      filename = File.basename(path, File.extname(path))
      transcode_and_create(TvShow, path, "/media/anthony/Slowsto/transcoded/#{filename}.webm", File.dirname(path) + "/#{filename}.webm")
    end

    return [successes, failures]
  end

  def transcode_and_create(klass, input_path, transcode_path, eventual_path)
    TranscoderWorker.perform_async(klass, input_path, transcode_path, eventual_path)
  end

end
