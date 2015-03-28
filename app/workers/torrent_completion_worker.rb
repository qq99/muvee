class TorrentCompletionWorker
  include Sidekiq::Worker

  def perform
    Torrent.all.each do |torrent|
      status = torrent.completion_status
      if status == "missing"
        torrent.destroy
      elsif status == "complete"
        Rails.logger.info "Torrent complete, moving"
        torrent.finalize
      end
    end
  end
end
