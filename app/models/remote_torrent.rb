class RemoteTorrent < Hashie::Mash

  def ratio
    @ratio ||= (seeders.to_f / leechers.to_f) if seeders.present? && leechers.present?
  end

end
