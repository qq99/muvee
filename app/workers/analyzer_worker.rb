class AnalyzerWorker
  include Sidekiq::Worker
  sidekiq_options queue: :analyze, retry: false

  def perform(opts)
    Series.first(30).each do |series|
      ReanalyzerWorker.perform_async(Series.name, series.id)
    end
    #
    # Movie.all.each do |movie|
    #   ReanalyzerWorker.perform_async(Movie.name, movie.id)
    # end
  end
end
