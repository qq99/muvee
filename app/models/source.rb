class Source < ActiveRecord::Base
  include AssociatesSelfWithVideo
  include HasMetadata
  belongs_to :video, counter_cache: true

  validates :raw_file_path, uniqueness: true
  before_validation :set_quality, on: :create
  before_validation :associate_self_with_video, on: :create

  after_create :trigger_post_source_actions

  def set_quality
    self.quality = guessed[:quality]
  end

  def is_3d?
    is_3d.present?
  end

  def file_is_present_and_exists?
    raw_file_path.present? && file_exists?
  end

  def file_exists?
    File.exist?(raw_file_path)
  end

  def reanalyze
    if file_is_present_and_exists?
      true
    else
      self.destroy
      false
    end
  end

  def filename
    File.basename(raw_file_path)
  end

  def containing_folder
    raw_file_path.remove(filename)
  end

  def extension
    File.extname(raw_file_path)[1..-1]
  end

  def trigger_post_source_actions
    self.video.post_sourced_actions
  end

  def rename(new_name)
    new_path = File.join(containing_folder, new_name).to_s
    FileUtils.mv(raw_file_path, new_path)
    self.update_attribute(:raw_file_path, new_path)
  end

  def move_to(new_path)
    begin
      FileUtils.mv(raw_file_path, new_path)
      self.update_attribute(:raw_file_path, new_path)
    rescue => e
      raise e
    end
  end

end
