class TvShow < Video
  include HasMetadata

  belongs_to :series
  before_create :guessit
  after_create :associate_with_series

  FORMATS = {
    standard: /([\w\-\.\_\s]*)S(\d+)(?:\D*)E(\d+)/i
  }.freeze

  def associate_with_series
    if series_metadata
      series_tvdb_id = series_metadata[:id]
      series_name = series_metadata[:SeriesName] || self.title

      series = Series.find_by_tvdb_id(series_tvdb_id) || Series.create(tvdb_id: series_tvdb_id, title: series_name)
      series.tv_shows << self
      series.save

      self.title = series_name
      self.save
    end
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
