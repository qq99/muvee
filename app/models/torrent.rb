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
    config = ApplicationConfiguration.first
    folder = config.movie_sources.first

    service.move_torrent({transmission_id: transmission_id, to: folder})
  end

  def move_to_tv_show_folder
    config = ApplicationConfiguration.first
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
      Video::SERVABLE_FILETYPES.any? {|type| filename.include? type}
    end
  end

  def percentage
    service.percentage_done(transmission_id)
  end

  def move_to_tv_folder
  end

  def completion_status
    service.check_completion_status(transmission_id)
  end
end
