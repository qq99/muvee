module FolderFileLister

  def get_files_in_folders(folders)
    files = []
    folders.each do |folder|
      folder << "/" if folder[-1] != "/" # append trailing slash if not present
      all_files_in_folder = Dir["#{folder}**/*.*"]
      files.push(*all_files_in_folder)
    end
    files
  end

end
