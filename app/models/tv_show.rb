class TvShow < Video
  include HasMetadata

  belongs_to :series, counter_cache: true
  before_create :guessit
  after_create :extract_metadata
  after_create :associate_with_series
  after_create :associate_with_genres

  scope :latest, -> {order(season: :desc, episode: :desc)}
  scope :release_order, -> {order(season: :asc, episode: :asc)}

  def associate_with_series
    series = Series.find_or_create_by(title: self.title)
    series.tv_shows << self
    #series.tvdb_series_result = episode_metadata_search
    series.save
  end

  def season_episode
    self.class.format_season_and_episode(season, episode)
  end

  def self.format_season_and_episode(s, e)
    "S" + s.to_s.rjust(2, '0') + "E" + e.to_s.rjust(2, '0')
  end

  def associate_with_genres
    return if series_metadata[:Genre].blank?

    self.genres.destroy_all

    listed_genres = compute_genres(series_metadata[:Genre])
    listed_genres.each do |genre_name|
      self.genres << Genre.find_or_create_by(name: genre_name)
    end
    self.save if listed_genres.any?
  end

  def extract_metadata
    self.title = metadata[:SeriesName]
    self.overview = episode_specific_metadata[:Overview]
    self.episode_name = episode_specific_metadata[:EpisodeName]
    self
  end

  def guessit
    if raw_file_path.present?
      guessed = Guesser::TvShow.guess_from_filepath(raw_file_path)
      self.title = guessed[:title]
      self.season = guessed[:season]
      self.episode = guessed[:episode]
      self.quality = guessed[:quality]
    else
      self.title = "Unknown"
    end
    self
  end

  def reanalyze
    super
    guessit
    associate_with_series
    associate_with_genres
    extract_metadata
    self.save
  end

  def redownload; end
  def redownload_missing; end

end
