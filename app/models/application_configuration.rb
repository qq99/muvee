class ApplicationConfiguration < ActiveRecord::Base
  validates :transcode_folder, presence: true, if: :transcode_media
  validate :transcode_folder_exists?, if: :transcode_media
  validate :torrent_download_folder_exists?

  before_validation :sanitize_media_sources

  def sanitize_media_sources
    self.tv_sources = tv_sources.compact.uniq.map(&:strip)
    self.movie_sources = movie_sources.compact.uniq.map(&:strip)

    tv_sources.each do |folder|
      if !File.exists?(folder.shellescape)
        self.errors.add folder, "does not exist, or we don't have access to it"
      end
    end
    movie_sources.each do |folder|
      if !File.exists?(folder.shellescape)
        self.errors.add folder, "does not exist, or we don't have access to it"
      end
    end
  end

  def transcode_folder_exists?
    return unless transcode_folder.present?
    if !File.exists?(transcode_folder.to_s)
      self.errors.add transcode_folder || "Transcode folder", "does not exist, or we don't have access to it"
    end
  end

  def torrent_download_folder_exists?
    return unless torrent_start_path.present?
    if !File.exists?(torrent_start_path.to_s)
      self.errors.add torrent_start_path || "Torrent storage path", "does not exist, or we don't have access to it"
    end
  end
end
