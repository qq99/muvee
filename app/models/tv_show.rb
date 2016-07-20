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

  def associate_self_with_series
    found_series = if series.blank?
      if season.present? && episode.present? && title.present?
        s = Series.find_or_create_by(title: title)
        s.reanalyze(true)
        s
      end
    end

    if found_series.present?
      existing_episode = found_series.tv_shows.find_by(season: season, episode: episode)
      if existing_episode.present? && existing_episode != self
        existing_episode.sources += self.sources
        self.sources = []
        existing_episode.save
        self.destroy
        existing_episode.reanalyze
      else
        self.series = found_series
        self.save
      end
    end
  end

  def reanalyze(deep_reanalyze = false)
    video_still_exists = associate_self_with_series
    super if video_still_exists
  end

  def redownload; end
  def redownload_missing; end

end
