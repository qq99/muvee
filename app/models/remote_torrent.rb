class RemoteTorrent < Hashie::Mash
  GOOD_SEED_COUNT_THRESHOLD = (50).freeze
  GOOD_RATIO_THRESHOLD = (0.5).freeze

  def ratio
    @ratio ||= (seeders.to_f / leechers.to_f) if seeders.present? && leechers.present?
  end

  def good_seeds?
    seeders.present? &&
      seeders > GOOD_SEED_COUNT_THRESHOLD
  end

  def good_ratio?
    ratio.present? &&
      ratio.finite? &&
      ratio > GOOD_RATIO_THRESHOLD
  end

  def dead?
    seeders.blank? || seeders == 0
  end

end
