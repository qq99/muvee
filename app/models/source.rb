class Source < ActiveRecord::Base
  include HasMetadata
  belongs_to :video, counter_cache: true

  before_validation :start_guessing, only: :create

  def is_3d?
    is_3d.present?
  end

  def file_is_present_and_exists?
    raw_file_path.present? && File.exist?(raw_file_path)
  end

end
