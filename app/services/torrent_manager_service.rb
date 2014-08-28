class TorrentManagerService

  def client
    @client ||= TransmissionApi::Client.new(url: "http://127.0.0.1:9091/transmission/rpc")
  end

  def self.find_sources(remote_movie)
    sources = YtsFindResult.get(remote_movie.fetch_imdb_id).data[:MovieList]
    # TODO make a proper model for a concept of a Source and how fresh it is, along with the magnet URL and torrent URL
    # so that we can use that model to download later / look at progress, and so on

    sources.sort_by {|s| s[:Quality].to_i} # TODO this doesn't work
    sources.group_by do |source|
      source[:Quality]
    end
  end

  def self.download_movie(remote_movie)

    #@client.create()
    # find a torrent
    # download it
    # query it until its done
    # move it into the right spot
    # Movie.create with it
  end

end
