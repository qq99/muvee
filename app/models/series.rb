class Series < ActiveRecord::Base
  include HasMetadata
  include DownloadFile

  after_create :download_images
  before_destroy :destroy_images

  POSTER_FOLDER = Rails.root.join('public', 'posters')
  FANART_FOLDER = Rails.root.join('public', 'fanart')
  BANNER_FOLDER = Rails.root.join('public', 'banners')

  has_many :tv_shows
  has_one :tvdb_series_result
  has_one :last_watched_video, class_name: "Video", primary_key: "last_watched_video_id", foreign_key: "id"

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
    remote_filename = "http://thetvdb.com/banners/" + series_metadata[:fanart]
    output_filename = UUID.generate(:compact) + File.extname(remote_filename)
    output_path = FANART_FOLDER.join(output_filename)

    if download_file(remote_filename, output_path)
      self.fanart_path = output_filename
    end
  end

  def download_banner
    remote_filename = "http://thetvdb.com/banners/" + series_metadata[:banner]
    output_filename = UUID.generate(:compact) + File.extname(remote_filename)
    output_path = BANNER_FOLDER.join(output_filename)

    if download_file(remote_filename, output_path)
      self.banner_path = output_filename
    end
  end

  def download_poster
    remote_filename = "http://thetvdb.com/banners/" + series_metadata[:poster]
    output_filename = UUID.generate(:compact) + File.extname(remote_filename)
    output_path = POSTER_FOLDER.join(output_filename)

    if download_file(remote_filename, output_path)
      self.poster_path = output_filename
    end
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
