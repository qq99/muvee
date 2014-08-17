class Movie < Video
  include DownloadFile

  POSTER_FOLDER = Rails.root.join('public', 'posters')

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
end
