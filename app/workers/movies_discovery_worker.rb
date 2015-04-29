class MoviesDiscoveryWorker
  include Sidekiq::Worker
  sidekiq_options queue: :movies_discovery, retry: false

  def perform
    YtsQueryService.find_more
  end
end
