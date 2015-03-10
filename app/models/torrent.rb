class Torrent < ActiveRecord::Base

  belongs_to :video

  def service
    @service ||= TorrentManagerService.new
  end

  def move_to_proper_folder
    if video_type == "Movie"
      move_to_movie_folder
    elsif video_type == "TvShow"
      move_to_tv_show_folder
    end
  end

  def move_to_movie_folder
    config = APP_CONFIG
    folder = config.movie_sources.first

    service.move_torrent({transmission_id: transmission_id, to: folder})
  end

  def move_to_tv_show_folder
    config = APP_CONFIG
    folder = config.tv_sources.first

    service.move_torrent({transmission_id: transmission_id, to: folder})
  end

  def info
    service.find(transmission_id).with_indifferent_access
  end

  def files_by_size
    info[:files].sort_by{ |f| f[:length] }.reverse
  end

  def video_files
    files_by_size.select do |file|
      filename = file[:name]
      Video::SERVABLE_CONTAINERS.any? {|type| filename.include? type}
    end
  end

  def set_video_to_local_after_complete
    return if video.blank? || video.local?
    return if video.is_tv? # we don't create a model for TV shows
    config = APP_CONFIG
    folders = config.movie_sources
    search_for = files_by_size.first[:name]
    true_path = find_file_in_folders(search_for, folders).first
    video.raw_file_path = true_path
    video.status = "local"
    video.shellout_and_grab_duration
    video.create_initial_thumb
    video.save
  end

  def find_file_in_folders(target, folders)
    files = []
    folders.each do |folder|
      folder = "#{folder}/" if folder[-1] != "/" # append trailing slash if not there
      all_files_in_folder = Dir["#{folder}**/*.*"]
      files.push(*all_files_in_folder)
    end

    files.select { |f| f.include? target }
  end

  def percentage
    service.percentage_done(transmission_id)
  end

  def move_to_tv_folder
  end

  def completion_status
    service.check_completion_status(transmission_id)
  end

  def torrent_name
    service.find(transmission_id)["name"]
  end

  def summary
    {
      video_id: video_id,
      video_type: video_type,
      video_name: video.try(:title) || torrent_name,
      progress: percentage
    }
  end
end
