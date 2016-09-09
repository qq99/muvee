class TorrentInfoChannel < ApplicationCable::Channel
  def subscribed
    torrent_info
  end

  def torrent_info
    silence_action do
      payload = Torrent.all.map(&:summary)
      transmit(payload)
    end
  end
end
