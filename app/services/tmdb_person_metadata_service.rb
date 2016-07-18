class TmdbPersonMetadataService < TmdbService

  def initialize(tmdb_id)
    raise ArgumentError.new('Must supply a tmdb id') unless tmdb_id.present?
    @tmdb_id = tmdb_id
  end

  def run
    data = get_data
    create_or_update_person(data)
  end

  private

  def tmdb_id
    @tmdb_id
  end

  # https://api.themoviedb.org/3/person/91606?api_key=a533c4925884599fa704aaf5a9006983&append_to_response=images
  def create_or_update_person(data)
    person = Person.find_or_initialize_by(tmdb_id: tmdb_id)

    person.biography = data.biography
    person.homepage = data.homepage
    person.full_name = data.name
    begin
      person.birthday = Time.parse(data.birthday) if data.birthday.present?
    rescue => e
    end
    begin
      person.deathday = Time.parse(data.deathday) if data.deathday.present?
    rescue => e
    end
    person.popularity = data.popularity
    person.adult = data.adult
    person.aliases = data.also_known_as.join(',') if data.also_known_as.present?
    person.imdb_id = data.imdb_id
    person.homepage = data.homepage
    person.gender = case data.gender
    when 2
      'Male'
    else
      'Female'
    end
    person.birthplace = data.place_of_birth

    person.images.destroy_all
    person.images = associate_images(data)

    person.save
  end

  def associate_images(data)
    profiles = data.images_.profiles || []
    profiles.map do |image|
      ProfileImage.new(
        aspect_ratio: image.aspect_ratio,
        width: image.width,
        height: image.height,
        language: image.iso_639_1,
        vote_average: image.vote_average,
        vote_count: image.vote_count,
        path: image.file_path
      )
    end
  end

  def url
    "https://api.themoviedb.org/3/person/#{tmdb_id}?api_key=#{Figaro.env.tmdb_api_key}&append_to_response=images"
  end
  
end
