class TmdbEpisodeMetadataService < TmdbService
  def initialize(series_id, season_number)
    raise ArgumentError.new("Must supply muvee series_id") unless series_id.present?
    raise ArgumentError.new("Must supply season number") unless season_number.present?
    @series = Series.find(series_id)
    @tmdb_id = @series.tmdb_id
    @season_number = season_number
  end

  def run
    data = get_data
    create_or_update_episodes(data)
  end

  private

  def series
    @series
  end

  def season_number
    @season_number
  end

  def create_or_update_episodes(data)
    return unless data.episodes.present?
    data.episodes.each do |episode|
      ep = series.tv_shows.find_or_initialize_by(season: episode.season_number, episode: episode.episode_number)

      ep.title = series.title
      ep.episode_name = episode.name
      ep.overview = episode.overview
      if episode.still_path
        ep.images = [StillImage.new(
          path: episode.still_path
        )]
      else
        ep.images = []
      end
      ep.mpaa_rating = series.content_rating
      begin
        ep.released_on = Time.parse(episode.air_date) if episode.air_date.present?
      rescue => e
      end
      ep.save
    end
  end

  def url
    "https://api.themoviedb.org/3/tv/#{series.tmdb_id}/season/#{season_number}?api_key=#{Figaro.env.tmdb_api_key}"
  end
end
