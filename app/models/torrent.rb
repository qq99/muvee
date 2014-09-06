class Torrent < ActiveRecord::Base

  def service
    @service ||= TorrentManagerService.new
  end

  def move_to_movie_folder
    config = ApplicationConfiguration.first
    movie_folder = config.movie_sources.first

    service.move_torrent({transmission_id: transmission_id, to: movie_folder})
  end

  def move_to_tv_folder
  end

  def completion_status
    service.check_completion_status(transmission_id)
  end
end
