class Torrent < ActiveRecord::Base

  belongs_to :video

  def service
    @service ||= TorrentManagerService.new
  end

  def config
    @config ||= ApplicationConfiguration.first
  end

  def move_to_proper_folder
    if video_type == "Movie"
      folder = config.movie_sources.first
      service.move_torrent(transmission_id: transmission_id, to: folder)
    elsif video_type == "TvShow"
      folder = config.tv_sources.first
      service.move_torrent(transmission_id: transmission_id, to: folder)
    end
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

  def finalize
    move_to_proper_folder
    service.remove_torrent(transmission_id: transmission_id)
    self.destroy
    create_source
  end

  def create_source
    if video.present?
      largest_file = files_by_size.first[:name]
      resulting_file = post_move_filepath(largest_file)
      video.sources.create(raw_file_path: resulting_file)
    else # this shouldn't happen anymore, but potentially could if you were to somehow add a torrent external to current methods
      MediaScannerWorker.perform_async
    end
  end

  def post_move_filepath(search_for)
    folders = config.movie_sources + config.tv_sources
    find_file_in_folders(search_for, folders).first
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

  def completion_status
    service.check_completion_status(transmission_id)
  end

  def torrent_name
    service.find(transmission_id)["name"]
  end

  def summary
    {
      id: id,
      video_id: video_id,
      video_type: video_type,
      video_name: video.try(:title) || torrent_name,
      current: percentage,
      status: completion_status,
      max: 100.0
    }
  end
end
