class AnalyzerWorker
  include Sidekiq::Worker

  def perform
    TvShow.all.each do |tv_show|
      tv_show.reanalyze
    end
  end
end
