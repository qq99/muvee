class TvShow < Video
  include HasMetadata

  belongs_to :series
  before_create :guessit
  after_create :associate_with_series
  after_create :extract_metadata

  # More formats available at https://github.com/midgetspy/Sick-Beard/blob/development/sickbeard/name_parser/regexes.py
  FORMATS = {
    standard: /([\w\-\.\_\(\) ]*)S(\d+)(?:\D*)E(\d+)/i,
    fov_repeat: /([\w\-\.\(\) ]*) - (\d+)(?:\D+)(\d+)/i
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
      quality, remaining_filename = filename_without_quality(filename_no_extension)
      containing_foldername = raw_file_path.split("/")[-2]

      if matches = guess_info_from_string(remaining_filename) || guess_info_from_string(containing_foldername)
        self.title, self.season, self.episode = matches
      end

      if !self.title.present?
        self.title = pretty_title(remaining_filename)
      end
    end
  end

  def guess_info_from_string(from)
    TvShow::FORMATS.each do |name, regex|
      matches = regex.match(from)
      if matches.present? && matches.length == 4
        title = pretty_title matches[1]
        season = matches[2].to_i
        episode = matches[3].to_i
        return [title, season, episode]
      end
    end
    nil
  end

  def reanalyze
    guessit
    self.save
    associate_with_series
    extract_metadata
  end

end
