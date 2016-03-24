class TorrentCompletionWorker
  include Sidekiq::Worker

  def perform
    return unless Rails.configuration.control_transmission
    
    Torrent.all.each do |torrent|
      status = torrent.completion_status
      if status == "missing"
        torrent.destroy
      elsif status == "complete"
        Rails.logger.info "Torrent complete, moving"
        torrent.finalize
      end
      torrent.video.try(:reanalyze)
    end
  end
end
