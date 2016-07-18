class TmdbEpisodeMetadataService
  def initialize(series_id, season_number)
    raise ArgumentError.new("Must supply muvee series_id") unless series_id.present?
    raise ArgumentError.new("Must supply season number") unless season_number.present?
    @series = Series.find(series_id)
    @tmdb_id = @series.tmdb_id
    @season_number = season_number
  end

  def run
    response = perform_request

    data = case response.code
    when 200
      Hashie::Mash.new(JSON.parse(response.body))
    else
      Hashie::Mash.new
    end

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
    data.episodes.each do |episode|
      ep = series.tv_shows.find_or_initialize_by(season: episode.season_number, episode: episode.episode_number)

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
        ep.released_on = Time.parse(data.air_date) if data.air_date.present?
      rescue => e
      end
      ep.save
    end
  end

  def perform_request
    Typhoeus.get(
      "https://api.themoviedb.org/3/tv/#{series.tmdb_id}/season/#{season_number}?api_key=#{Figaro.env.tmdb_api_key}",
      followlocation: true,
      accept_encoding: "gzip"
    )
  end
end
