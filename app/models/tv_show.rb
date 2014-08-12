class TvShow < Video
  include HasMetadata

  belongs_to :series
  before_create :guessit
  after_create :associate_with_series
  after_create :extract_metadata

  FORMATS = {
    standard: /([\w\-\.\_\s]*)S(\d+)(?:\D*)E(\d+)/i
  }.freeze

  def associate_with_series
    if series_tvdb_id = metadata[:seriesid]
      series_name = metadata[:SeriesName] || self.title

      series = Series.find_by_tvdb_id(series_tvdb_id) || Series.create(
        tvdb_id: series_tvdb_id,
        title: series_name,
        overview: metadata[:Overview],
        tvdb_rating: metadata[:Rating],
        tvdb_rating_count: metadata[:RatingCount],
        status: metadata[:Status]
      )
      series.tv_shows << self
      series.tvdb_series_result = episode_metadata_search
      series.save
    end
  end

  def extract_metadata
    self.title = metadata[:SeriesName]
    self.overview = episode_specific_metadata[:Overview]
    self.episode_name = episode_specific_metadata[:EpisodeName]
    self.save
  end

  def guessit
    if filename_no_extension.empty?
      self.title = "Unknown"
    else
      TvShow::FORMATS.each do |name, regex|
        matches = regex.match(filename_no_extension)
        if matches.present? && matches.length == 4
          self.title = pretty_title matches[1]
          self.season = matches[2].to_i
          self.episode = matches[3].to_i
        end
      end

      if !self.title.present?
        self.title = pretty_title filename_no_extension
      end
    end
  end
end
