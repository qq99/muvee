class SeriesAnalyzerWorker
  include Sidekiq::Worker
  sidekiq_options queue: :default, retry: false

  def perform(id)
    series = Series.find(id.to_i)
    series.reanalyze
  end
end
