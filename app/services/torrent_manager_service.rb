class TorrentManagerService

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

  def check_completion_status(transmission_id)
    torrent = client.all.find { |t| t["addedDate"] == transmission_id }
    if torrent.blank?
      return "missing"
    else
      if torrent["isFinished"]
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
      tid = find_id_by_transmission_id(client, opts[:transmission_id])
    end

    client.move(tid, opts[:to])
  end

  def find_id_by_transmission_id(transmission_id)
    all_torrents = client.all
    torrent = all_torrents.find { |t| t["addedDate"] == transmission_id }
    torrent["id"]
  end

  def self.find_sources(remote_movie)
    sources = YtsFindResult.get(remote_movie.fetch_imdb_id).data[:MovieList]
    sources.sort_by {|s| s[:Quality].to_i} # TODO this doesn't work
    sources.group_by do |source|
      source[:Quality]
    end
  end

  def download_movie(url, remote_video = nil)
    record = Torrent.new(source: url)

    result = client.create(url)
    if result.blank? || result["id"].blank?
      throw "Failed to create torrent"
    end
    tid = result["id"]

    move_result = client.move(tid, start_path)

    full_result = client.all.find { |t| t["id"] == tid } # has a timestamp we can use as an ID
    throw "Unable to find full result" if full_result.blank?
    throw "New record does not have an added date" if full_result["addedDate"].blank?

    record.transmission_id = full_result["addedDate"]

    record.save
  end

end
