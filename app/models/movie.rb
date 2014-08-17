class Movie < Video
  include DownloadFile

  # before_create :guessit
  # after_create :extract_metadata

  POSTER_FOLDER = Rails.root.join('public', 'posters')

  FORMATS = {
    name_and_year: %r{
      ([\w\-\.\_\s]*)
      [\ \_\.\[]{1}([\d]{4})[\ \_\.\[]?
    }xi
  }.freeze

  def metadata
    @metadata ||= OmdbSearchResult.get(self.title).raw_value || {}
  end

  def extract_metadata
    self.title = metadata[:Title]
    self.released_on = Time.parse(metadata[:Released])
    self.overview = metadata[:Plot]
    self.language = metadata[:Language]
    self.country = metadata[:Country]
    self.awards = metadata[:Awards]
  end

  def download_poster
    remote_filename = metadata[:Poster]
    output_filename = UUID.generate(:compact) + File.extname(remote_filename)
    output_path = POSTER_FOLDER.join(output_filename)

    if download_file(remote_filename, output_path)
      self.poster_path = output_filename
    end
    self.save
  end

  def guessit
    if filename_no_extension.empty?
      self.title = "Unknown"
    else
      quality, remaining_filename = filename_without_quality(filename_no_extension)

      Movie::FORMATS.each do |name, regex|
        matches = regex.match(remaining_filename)
        if matches.present?
          self.title = pretty_title matches[1]
        end
      end

      if !self.title.present?
        self.title = pretty_title remaining_filename
      end
    end
  end
end
