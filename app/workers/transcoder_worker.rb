class TranscoderWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :transcode

  def perform
    Transcode.ready.sample.transcode
  end
end
