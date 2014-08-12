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

  def create_movies(folders)
    return [[], []] # not implemented yet
  end

  def create_tv_shows(folders)
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
      video = TvShow.new(raw_file_path: filepath)
      if video.save
        successes << video
      else
        failures << video
      end
    end

    return [successes, failures]
  end

end
