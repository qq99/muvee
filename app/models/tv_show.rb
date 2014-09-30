class TvShow < Video
  include HasMetadata

  belongs_to :series
  before_create :guessit
  after_create :associate_with_series
  after_create :associate_with_genres
  after_create :extract_metadata

  # More formats available at https://github.com/midgetspy/Sick-Beard/blob/development/sickbeard/name_parser/regexes.py
  FORMATS = {
    standard_repeat: /([\w\-\.\_\(\) ]*)S(\d+)(?:\D*)E(\d+)(?:.*)S(\d+)(?:\D*)E(\d+)/i,
    standard: /([\w\-\.\_\(\) ]*)S(\d+)(?:\D*)E(\d+)/i,
    fov_repeat: /([\w\-\.\(\) ]*)\D+?(\d+)(?:\D+)(\d+)/i
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

  def associate_with_genres
    return if series_metadata[:Genre].blank?

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
      if matches.present? && matches.length == 6
        title = pretty_title matches[1]
        season = matches[2].to_i
        episode = matches[3].to_i
        season2 = matches[4].to_i
        episode2 = matches[5].to_i
        return [title, season, episode, season2, episode2]
      end
    end
    nil
  end

  def reanalyze
    super
    guessit
    associate_with_series
    associate_with_genres
    extract_metadata
  end

  def redownload; end
  def redownload_missing; end

end
