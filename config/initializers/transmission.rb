if Rails.configuration.control_transmission

  if `ps aux | grep transmission-gt[k]` == ""
    puts '=> initializers/transmission: Transmission is not running! Starting it for you...'
    TorrentManagerService.start_transmission
  end
else
  puts '=> initializers/transmission: Opting not to control Transmission BitTorrent client'
end
