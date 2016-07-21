class TmdbTopRatedMovieDiscoveryService < TmdbService

  def initialize(page)
    raise ArgumentError.new("Must supply page") unless page.present?
    @page = page
  end

  def run
    data = get_data
    create_movies(data)
  end

  private

  def create_movies(data)
    movies = data.results || []

    movies.map do |movie|
      m = Movie.find_by(tmdb_id: movie.id)
      return if m.present?

      m = Movie.new
      m.tmdb_id = movie.id
      m.adult = movie.adult
      m.title = movie.title
      m.overview = movie.overview

      m.save
      m.reanalyze
      m
    end
  end

  def page
    @page
  end

  def url
    "https://api.themoviedb.org/3/movie/top_rated?api_key=#{Figaro.env.tmdb_api_key}&page=#{page}"
  end

end
