class MoviesDiscoveryWorker
  include Sidekiq::Worker
  sidekiq_options queue: :movies_discovery, retry: false

  def perform
    (1..100).each do |i|
      movies = TmdbTopRatedMovieDiscoveryService.new(i).run
      break if movies.present?
    end
  end

end
