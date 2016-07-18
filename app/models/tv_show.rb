class TvShow < Video
  include HasMetadata
  include AssociatesSelfWithGenres

  belongs_to :series, counter_cache: true
  # after_create :extract_metadata, unless: :reanalyzing_series
  # after_create :associate_with_series, unless: :reanalyzing_series
  # after_create :associate_with_genres

  validate :unique_episode_in_season, on: :create

  scope :latest, -> {order(season: :desc, episode: :desc)}
  scope :release_order, -> {order(season: :asc, episode: :asc)}

  attr_accessor :reanalyzing_series

  def unique_episode_in_season
    if series.present?
      self.errors.add(:unique_episode_in_season, 'Season&Episode must be unique within the context of a season') if series.tv_shows.find_by(season: season, episode: episode).present?
    end
  end

  def associate_with_series
    old_series = self.series.presence

    self.series = if season.blank? || episode.blank?
      nil
    else
      Series.find_or_create_by(title: title)
    end
    self.save

    Series.reset_counters(self.series.id, :tv_shows) if self.series.try(:persisted?)
    Series.reset_counters(old_series.id, :tv_shows) if old_series.present?
  end

  def season_episode
    self.class.format_season_and_episode(season, episode)
  end

  def self.format_season_and_episode(s, e)
    "S" + s.to_s.rjust(2, '0') + "E" + e.to_s.rjust(2, '0')
  end

  def associate_with_genres
    return if series_metadata[:Genre].blank?
    genres = series_metadata[:Genre].split(/,|\|/)
    associate_self_with_genres(genres)
  end

  def extract_metadata
    self.title = metadata[:SeriesName].presence || self.title
    self.overview = episode_specific_metadata[:Overview].presence || self.overview
    self.episode_name = episode_specific_metadata[:EpisodeName].presence || self.episode_name
    self.season = episode_specific_metadata[:SeasonNumber].presence || self.season
    self.episode = episode_specific_metadata[:EpisodeNumber].presence || self.episode
  end

  def reanalyze
    super
    associate_with_series

    if series.blank? && sources.count == 0
      self.destroy
    else
      associate_with_genres
      extract_metadata
      self.save
    end
  end

  def redownload; end
  def redownload_missing; end

end
