class SourceCreationWorker
  include Sidekiq::Worker
  sidekiq_options queue: :scan

  def perform(type, raw_file_path, video_id)
    Source.create(
      type: type,
      raw_file_path: raw_file_path,
      video_id: video_id
    )
  end
end
