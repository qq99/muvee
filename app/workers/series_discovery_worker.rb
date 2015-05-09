class SeriesDiscoveryWorker
  include Sidekiq::Worker
  sidekiq_options queue: :series_discovery, retry: false

  def publish(event)
    @redis ||= Redis.new
    event = event.merge(type: 'SeriesDiscoveryWorker')
    @redis.publish(:sidekiq, event.to_json)
  end

  def perform
    series_names = EztvSeriesListResult.search

    max_size = series_names.size
    publish({status: "scanning", current: 0, max: max_size})
    series_names.each_with_index do |series_name, i|
      publish({status: "scanning", current: i, max: max_size, substatus: series_name})
      Series.create(title: series_name)
    end
    publish({status: "complete", current: max_size, max: max_size, substatus: "Done!"})
  end
end
