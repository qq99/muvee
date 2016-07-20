class TvShow < Video
  belongs_to :series, counter_cache: true
  validate :unique_episode_in_season, on: :create

  scope :latest, -> {order(season: :desc, episode: :desc)}
  scope :release_order, -> {order(season: :asc, episode: :asc)}

  attr_accessor :reanalyzing_series

  def unique_episode_in_season
    if series.present?
      self.errors.add(:unique_episode_in_season, 'Season&Episode must be unique within the context of a season') if series.tv_shows.find_by(season: season, episode: episode).present?
    end
  end

  def season_episode
    self.class.format_season_and_episode(season, episode)
  end

  def self.format_season_and_episode(s, e)
    "S" + s.to_s.rjust(2, '0') + "E" + e.to_s.rjust(2, '0')
  end

  def reanalyze(deep_reanalyze = false)
    if series.blank?
      found_series = if season.present? && episode.present? && title.present?
        Series.find_or_create_by(title: title)
      end
      found_series.reanalyze(true)
    end

    super
  end

  def redownload; end
  def redownload_missing; end

end
