class TmdbSeriesMetadataService
  def initialize(tmdb_id)
    raise ArgumentError.new('Must supply a tmdb id') unless tmdb_id.present?
    @tmdb_id = tmdb_id
  end

  def run
    response = perform_request

    data = case response.code
    when 200
      Hashie::Mash.new(JSON.parse(response.body))
    else
      Hashie::Mash.new
    end

    create_or_update_series(data)
  end

  private

  def tmdb_id
    @tmdb_id
  end

  def create_or_update_series(data)
    series = Series.find_or_initialize_by(tmdb_id: tmdb_id)

    series.imdb_id = data.external_ids.imdb_id
    series.tvdb_id = data.external_ids.tvdb_id
    series.freebase_id = data.external_ids.freebase_id
    series.freebase_mid = data.external_ids.freebase_mid
    series.tvrage_id = data.external_ids.tvrage_id

    series.title = data.name
    series.overview = data.overview
    series.website = data.homepage
    series.popularity = data.popularity
    series.country = data.origin_country.first
    series.language = data.original_language
    begin
      series.first_air_date = Time.parse(data.first_air_date) if data.first_air_date.present?
    rescue => e
    end
    begin
      series.last_air_date = Time.parse(data.last_air_date) if data.last_air_date.present?
    rescue => e
    end
    series.ended = !data.in_production
    content_ratings = data.content_ratings_.results || []
    series.content_rating = content_ratings.first.try(:rating)
    series.save

    series.genres = associate_genres(data)
    series.images.destroy_all
    series.images = associate_images(data)

    series.people = []
    series.people << associate_people(data, series)

    series.save

    associate_episodes_of_series(data.number_of_seasons, series)
  end

  def associate_genres(data)
    genres = data.genres.map(&:name).compact.map(&:strip).reject(&:blank?).uniq

    resulting_genres = genres.map do |genre_name|
      genre_name = Genre.normalized_name(genre_name)
      genre = Genre.find_or_create_by(name: genre_name)
      genre
    end
  end

  def associate_episodes_of_series(seasons_count, series)
    seasons_count.times do |i|
      TmdbEpisodeMetadataService.new(series.id, i+1).run
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
        path: image.file_path
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
        path: image.file_path
      )
    end

    resulting_images
  end

  def associate_people(data, series)
    people = associate_actors(data, series) + associate_crew(data, series)
    people = people.uniq(&:id)
    people
  end

  def associate_actors(data, series)
    actors = data.credits.cast

    resulting_people = actors.map do |actor|
      person = Person.find_or_initialize_by(full_name: actor.name)
      person.tmdb_id = actor.id
      role = person.roles.find_or_initialize_by(series_id: series.id)
      role.character = actor.character
      role.department = 'Performance'
      role.job_title = 'Actor'
      role.save

      person
    end
  end

  def associate_crew(data, series)
    crew = data.credits.crew

    resulting_people = crew.map do |crew_member|
      person = Person.find_or_initialize_by(full_name: crew_member.name)
      person.tmdb_id = crew_member.id
      role = person.roles.find_or_initialize_by(series_id: series.id)
      role.department = crew_member.department
      role.job_title = crew_member.job
      role.save

      person
    end
  end

  def perform_request
    Typhoeus.get(
      "https://api.themoviedb.org/3/tv/#{tmdb_id}?api_key=#{Figaro.env.tmdb_api_key}&append_to_response=credits,external_ids,content_ratings,images",
      followlocation: true,
      accept_encoding: "gzip"
    )
  end

end
