class Movie < Video
  include DownloadFile

  before_create :guessit
  after_create :extract_metadata
  after_create :download_poster
  before_destroy :destroy_images

  POSTER_FOLDER = Rails.root.join('public', 'posters')

  FORMATS = {
    name_and_year: %r{
      ([\w\-\.\_\s]*)
      [\(\ \_\.\[]{1}([\d]{4})[\)\ \_\.\[]?
    }xi
  }.freeze

  def metadata
    @metadata ||= OmdbSearchResult.get(self.title).raw_value || {}
  end

  def poster_url
    "/posters/#{poster_path}"
  end

  def extract_metadata
    self.title = metadata[:Title]
    self.released_on = Time.parse(metadata[:Released]) if metadata[:Released]
    self.overview = metadata[:Plot]
    self.language = metadata[:Language]
    self.country = metadata[:Country]
    self.awards = metadata[:Awards]
    self.save
  end

  def download_poster
    return if metadata[:Response] == "False"
    remote_filename = metadata[:Poster]
    return if remote_filename.blank?
    output_filename = UUID.generate(:compact) + File.extname(remote_filename)
    output_path = POSTER_FOLDER.join(output_filename)

    if download_file(remote_filename, output_path)
      self.poster_path = output_filename
    end
    self.save
  end

  def external_fanart
    return if imdb_id.blank?
    @fanart ||= FanartTvResult.get(imdb_id).data || {}
  end

  def imdb_id
    self.metadata[:imdbID]
  end

  def guessit
    if filename_no_extension.empty?
      self.title = "Unknown"
    else
      quality, remaining_filename = filename_without_quality(filename_no_extension)

      self.quality = quality if quality.present?

      Movie::FORMATS.each do |name, regex|
        matches = regex.match(remaining_filename)
        if matches.present?
          self.title = pretty_title matches[1]
          if matches[2].present?
            self.year = matches[2].to_i
          end
        end
      end

      if !self.title.present?
        self.title = pretty_title remaining_filename
      end
    end
  end

  def destroy_images
    begin
      File.delete(POSTER_FOLDER.join(poster_path))
    rescue Exception => e
      Rails.logger.info "Series#destroy_images: #{e}"
    end
  end
end
