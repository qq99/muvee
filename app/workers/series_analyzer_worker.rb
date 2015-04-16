class SeriesAnalyzerWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false
  sidekiq_options :queue => :analyze

  def perform(id)
    series = Series.find(id.to_i)
    series.reanalyze
  end
end
