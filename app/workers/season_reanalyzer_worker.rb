class SeasonReanalyzerWorker
  include Sidekiq::Worker
  sidekiq_options queue: :analyze

  def perform(series_id, season_number)
    TmdbEpisodeMetadataService.new(series_id, season_number).run
  end

end
