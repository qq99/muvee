class SeriesDiscoveryWorker
  include Sidekiq::Worker

  def perform
    series_names = EztvSeriesListResult.search

    series_names.each do |series_name|
      result = Series.create(title: series_name)
      puts "Creating series #{series_name}: #{result}"
    end
  end
end
