class TmdbMovieMetadataService

  def initialize(imdb_id)
    raise ArgumentError.new("You must supply an imdb id") unless imdb_id.present?
    @imdb_id = imdb_id
  end

  def run
    response = perform_request

    data = case response.code
    when 200
      Hashie::Mash.new(JSON.parse(response.body))
    else
      Hashie::Mash.new
    end

    create_or_update_movie(data)
  end

  private

  def create_or_update_movie(data)
    movie = Movie.find_or_initialize_by(imdb_id: data.imdb_id)

    movie.tmdb_id = data.tmdb_id
    movie.adult = data.adult
    movie.budget = data.budget
    movie.website = data.homepage
    movie.overview = data.overview
    movie.revenue = data.revenue
    movie.runtime_minutes = data.runtime
    movie.title = data.title
    movie.tagline = data.tagline
    movie.language = data.original_language

    movie.released_on = Time.parse(data.release_date) if data.release_date.present?

    movie.genres = associate_genres(data)
    movie.images.destroy_all
    movie.images = associate_images(data)

    movie.vote_average = data.vote_average
    movie.vote_count = data.vote_count

    movie.trailers.destroy_all
    movie.trailers = associate_trailers(data)

    movie.save

    movie.people = []
    movie.people << associate_people(data, movie)
    movie.save
  end

  def associate_trailers(data)
    trailers = data.trailers.youtube

    resulting_trailers = trailers.map do |trailer|
      trailer = Trailer.new(
        youtube_id: trailer.source,
        name: trailer.name
      )
    end
  end

  def associate_genres(data)
    genres = data.genres.map(&:name).compact.map(&:strip).reject(&:blank?).uniq

    resulting_genres = genres.map do |genre_name|
      genre_name = Genre.normalized_name(genre_name)
      genre = Genre.find_or_create_by(name: genre_name)
      genre
    end
  end

  def associate_images(data)
    resulting_images = []

    backdrops = data.images_.backdrops || []
    backdrops.each do |image|
      resulting_images << BackdropImage.new(
        aspect_ratio: image.aspect_ratio,
        width: image.width,
        height: image.height,
        language: image.iso_639_1,
        vote_average: image.vote_average,
        vote_count: image.vote_count,
        path: "http://image.tmdb.org/t/p/original#{image.file_path}"
      )
    end

    posters = data.images_.posters || []
    posters.each do |image|
      resulting_images << PosterImage.new(
        aspect_ratio: image.aspect_ratio,
        width: image.width,
        height: image.height,
        language: image.iso_639_1,
        vote_average: image.vote_average,
        vote_count: image.vote_count,
        path: "http://image.tmdb.org/t/p/original#{image.file_path}"
      )
    end

    resulting_images
  end

  def associate_people(data, movie)
    people = associate_actors(data, movie) + associate_crew(data, movie)
    people = people.uniq(&:id)
    people
  end

  def associate_actors(data, movie)
    actors = data.credits.cast

    resulting_people = actors.map do |actor|
      person = Person.find_or_initialize_by(full_name: actor.name)
      person.tmdb_id = actor.id
      role = person.roles.find_or_initialize_by(video_id: movie.id)
      role.character = actor.character
      role.department = 'Performance'
      role.job_title = 'Actor'
      role.save

      person
    end
  end

  def associate_crew(data, movie)
    crew = data.credits.crew

    resulting_people = crew.map do |crew_member|
      person = Person.find_or_initialize_by(full_name: crew_member.name)
      person.tmdb_id = crew_member.id
      role = person.roles.find_or_initialize_by(video_id: movie.id)
      role.department = crew_member.department
      role.job_title = crew_member.job
      role.save

      person

      person if person.persisted?
    end
  end

  def perform_request
    Typhoeus.get(
      "https://api.themoviedb.org/3/movie/#{@imdb_id}?api_key=#{Figaro.env.tmdb_api_key}&append_to_response=images,keywords,release_dates,credits,trailers",
      followlocation: true,
      accept_encoding: "gzip"
    )
  end

end
