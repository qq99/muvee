class TvShow < Video
  before_create :guessit

  attr_accessor :title, :episode, :season, :raw_file_path

  FORMATS = {
    standard: /([\w\-\.\_\s]*)S(\d+)(?:\D*)E(\d+)/i
  }.freeze

  def filename_no_extension
    return "" if raw_file_path.empty?

    @filename_no_extension ||= File.basename(raw_file_path, File.extname(raw_file_path))
  end

  private

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
