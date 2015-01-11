class MediaScannerWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false
  sidekiq_options :queue => :scan

  def perform
    config = ApplicationConfiguration.first
    return if config.blank?
    service = VideoCreationService.new({
      tv: config.tv_sources,
      movies: config.movie_sources
    })

    service.generate()
  end
end
