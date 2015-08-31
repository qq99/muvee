class TranscoderWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :transcode

  def num_currently_transcoding
    Sidekiq::Queue.new("transcode").entries.size
  end

  def perform
    return if num_currently_transcoding >= 2
    Transcode.ready.sample.try(:transcode) # may be none
    MediaScannerWorker.perform_async
  end
end
