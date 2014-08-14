class Series < ActiveRecord::Base
  include HasMetadata

  after_create :download_images
  before_destroy :destroy_images

  POSTER_FOLDER = Rails.root.join('public', 'posters')
  FANART_FOLDER = Rails.root.join('public', 'fanart')
  BANNER_FOLDER = Rails.root.join('public', 'banners')

  has_many :tv_shows
  has_one :tvdb_series_result
  has_one :last_watched_video, class_name: "Video"

  def banner_url
    series_metadata[:banner]
  end

  def overview
    series_metadata[:Overview]
  end

  def first_aired
    series_metadata[:FirstAired]
  end

  def network
    series_metadata[:Network]
  end

  def IMDB_id
    series_metadata[:IMDB_ID]
  end

  def poster_url
    "/posters/#{poster_path}"
  end

  def fanart_url
    "/fanart/#{fanart_path}"
  end

  def banner_url
    "/banners/#{banner_path}"
  end

  def download_images
    download_fanart
    download_banner
    download_poster
    self.save
  end

  def download_fanart
    remote_filename = series_metadata[:fanart]
    output_filename = UUID.generate(:compact) + ".jpg"
    output_path = FANART_FOLDER.join(output_filename)

    if download_file_from_tvdb(remote_filename, output_path)
      self.fanart_path = output_filename
    end
  end

  def download_banner
    remote_filename = series_metadata[:banner]
    output_filename = UUID.generate(:compact) + ".jpg"
    output_path = BANNER_FOLDER.join(output_filename)

    if download_file_from_tvdb(remote_filename, output_path)
      self.banner_path = output_filename
    end
  end

  def download_poster
    remote_filename = series_metadata[:poster]
    output_filename = UUID.generate(:compact) + ".jpg"
    output_path = POSTER_FOLDER.join(output_filename)

    if download_file_from_tvdb(remote_filename, output_path)
      self.poster_path = output_filename
    end
  end

  def download_file_from_tvdb(remote_filename, output_filename)
    return unless remote_filename.present? && output_filename.present?

    begin
      Net::HTTP.start("thetvdb.com") do |http|
        f = open(output_filename, "wb")
        response = http.get("/banners/#{remote_filename}")
        begin
          f.write(response.body)
        ensure
          f.close()
        end
      end
    rescue Exception => e
      Rails.logger.error "Could not download #{remote_filename}: #{e}"
      return false
    end
    true
  end

  def destroy_images
    begin
      File.delete(POSTER_FOLDER.join(poster_path))
      File.delete(BANNER_FOLDER.join(banner_path))
      File.delete(FANART_FOLDER.join(fanart_path))
    rescue Exception => e
      Rails.logger.info "Series#destroy_images: #{e}"
    end
  end
end
