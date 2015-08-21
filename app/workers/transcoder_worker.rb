class TranscoderWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :transcode

  def perform
    Transcode.ready.sample.try(:transcode) # may be none
  end
end
