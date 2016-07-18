class SeriesDiscoveryWorker
  include Sidekiq::Worker
  sidekiq_options queue: :series_discovery, retry: false

  def publish(event)
    event[:namespace] = 'SeriesDiscoveryWorker'
    ActionCable.server.broadcast "progress_reports", event
  end

  def perform
    series_names = EztvSeriesListResult.search

    max_size = series_names.size
    publish({status: "scanning", current: 0, max: max_size})
    series_names.each_with_index do |series_name, i|
      publish({status: "scanning", current: i, max: max_size, substatus: series_name})
      series = Series.create(title: series_name)
      ReanalyzerWorker.perform_async(Series.name, series.id) if series.persisted?
    end
    publish({status: "complete", current: max_size, max: max_size, substatus: "Done!"})
  end
end
