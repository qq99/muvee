class TorrentManagerService

  TRACKERS = %w(
    udp://open.demonii.com:1337
    udp://tracker.istole.it:80
    http://tracker.yify-torrents.com/announce
    udp://tracker.publicbt.com:80
    udp://tracker.openbittorrent.com:80
    udp://tracker.coppersurfer.tk:6969
    udp://exodus.desync.com:6969
    http://exodus.desync.com:6969/announce
  ).freeze

  def initialize
    config = ApplicationConfiguration.first
    @start_path = config.torrent_start_path
    throw "No initial path for torrent download" if @start_path.blank?
  end

  def client
    @client ||= TransmissionApi::Client.new(url: "http://127.0.0.1:9091/transmission/rpc")
  end

  def self.start_transmission
    transmission = fork do
      exec 'transmission-gtk'
    end
    Process.detach(transmission)
  end

  def percentage_done(transmission_id)
    torrent = find(transmission_id)
    return 0 if torrent.blank?
    torrent["percentDone"] * 100.0
  end

  def find(transmission_id)
    client.all.find { |t| t["addedDate"] == transmission_id }
  rescue Net::ReadTimeout
    nil
  end

  def check_completion_status(transmission_id)
    torrent = client.all.find { |t| t["addedDate"] == transmission_id }
    if torrent.blank?
      return "missing"
    else
      if torrent["percentDone"] == 1
        return "complete"
      else
        return "incomplete"
      end
    end
  end

  def move_torrent(opts)
    throw "Must supply a path to move torrent to" if opts[:to].blank?
    if opts[:id]
      tid = opts[:id]
    else
      tid = find_id_by_transmission_id(opts[:transmission_id])
    end

    client.move(tid, opts[:to])
  end

  def remove_torrent(opts)
    tid = find_id_by_transmission_id(opts[:transmission_id])

    client.remove(tid) if tid.present?
  end

  def find_id_by_transmission_id(transmission_id)
    all_torrents = client.all
    torrent = all_torrents.find { |t| t["addedDate"] == transmission_id }
    torrent["id"]
  rescue Net::ReadTimeout
    nil
  end

  def self.find_sources(remote_movie)
    sources = YtsFindResult.get(remote_movie.fetch_imdb_id).data[:data].try(:[], :movies).try(:first).try(:[], :torrents) || []

    # construct magnets
    sources.each do |source|
      source[:magnet] = self.construct_magnet_link(source[:hash], remote_movie.title)
    end

    sources
  end

  def self.construct_magnet_link(torrent_hash, name)
    trackers = TRACKERS.map{|t| CGI.escape(t)}.join("&tr=")
    "magnet:?xt=urn:btih:#{torrent_hash}&dn=#{CGI.escape(name)}&tr=#{trackers}"
  end

  def download_tv_show(url, remote_video = nil)
    download_video(url, "TvShow", remote_video)
  end

  def download_movie(url, remote_video = nil)
    download_video(url, "Movie", remote_video)
  end

  def download_video(url, video_type, remote_video = nil)
    already_exists = Torrent.find_by(source: url)
    if already_exists
      throw "Torrent for #{url} already exists."
    end

    record = Torrent.new(source: url, video_type: video_type)

    result = client.create(url)
    if result.blank? || result["id"].blank?
      throw "Torrent client failed to start torrent"
    end
    tid = result["id"]

    move_result = client.move(tid, @start_path)

    full_result = client.all.find { |t| t["id"] == tid } # has a timestamp we can use as an ID
    throw "Unable to find full result" if full_result.blank?
    throw "New record does not have an added date" if full_result["addedDate"].blank?

    record.transmission_id = full_result["addedDate"]
    if remote_video
      record.video_id = remote_video.id
      record.video_type = remote_video.class.name
      remote_video.update_attribute(:status, 'downloading')
    end

    record.save
  end

end
