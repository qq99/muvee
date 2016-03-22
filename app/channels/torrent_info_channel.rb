class TorrentInfoChannel < ApplicationCable::Channel
  def subscribed
    torrent_info
  end

  def unsubscribed
  end

  def torrent_info
    payload = Torrent.all.map(&:summary)
    transmit(payload)
  end
end
