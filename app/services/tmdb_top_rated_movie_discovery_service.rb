class TmdbTopRatedMovieDiscoveryService < TmdbService

  def initialize(page)
    raise ArgumentError.new("Must supply page") unless page.present?
    @page = page
  end

  def run
    data = get_data
    quick_create_movies(data)
  end

  private

  def page
    @page
  end

  def url
    "https://api.themoviedb.org/3/movie/top_rated?api_key=#{Figaro.env.tmdb_api_key}&page=#{page}"
  end

end
