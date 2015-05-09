class DeadFileFindingService
  include FolderFileLister

  def list_unsourced_files(folders_to_examine)
    all_files = get_files_in_folders(folders_to_examine)

    all_files.reject!{|file| File.directory?(file)}

    unsourced = all_files.select do |filename|
      !Source.exists?(raw_file_path: filename)
    end

    unsourced = unsourced.inject({}) do |hash, filename|
      data = {}

      if is_video_container?(filename) # potentially transcoded to another filename
        filename_no_extension = filename.gsub(File.extname(filename), '')
        if (source = Source.find_by(raw_file_path: filename_no_extension + ".mp4")) ||
           (source = Source.find_by(raw_file_path: filename_no_extension + ".webm"))

          data[:similar_source] = source
        end
      end

      hash[filename] = data
      hash
    end

    unsourced
  end

  def list_dead_sources
    dead_sources = Source.all.select do |source|
      !source.file_exists?
    end
  end

  def is_video_container?(filename)
    Video::VIDEO_CONTAINERS.include?(File.extname(filename))
  end

end
