class MediaScannerWorker
  include Sidekiq::Worker
  sidekiq_options queue: :scan, retry: false

  def perform
    config = ApplicationConfiguration.first
    return if config.blank?
    service = VideoCreationService.new(sources: {
      tv: config.tv_sources,
      movies: config.movie_sources
    })

    service.generate()
  end
end
