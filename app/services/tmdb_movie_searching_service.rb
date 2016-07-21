class TmdbMovieSearchingService < TmdbService
  def initialize(title)
    raise ArgumentError.new("You must supply a title") unless title.present?
    @title = title
  end

  def run
    data = get_data

    results = data.results || []
    results.first.try(:id)
  end

  private

  def title
    @title
  end

  def url
    "https://api.themoviedb.org/3/search/movie?api_key=#{Figaro.env.tmdb_api_key}&query=#{URI::encode(title)}"
  end
end
