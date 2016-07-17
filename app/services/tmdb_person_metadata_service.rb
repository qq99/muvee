class TmdbPersonMetadataService

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

    create_or_update_person(data)
  end

  private

  # https://api.themoviedb.org/3/person/91606?api_key=a533c4925884599fa704aaf5a9006983&append_to_response=images
  def create_or_update_person(data)
    person = Person.find_or_initialize_by(tmdb_id: @tdmb_id) do |p|
      p.biography = data.biography
      p.homepage = data.homepage
      p.full_name = data.name
      p.birthday = Time.parse(data.birthday) if data.birthday.present?
      p.deathday = Time.parse(data.deathday) if data.deathday.present?
      p.popularity = data.popularity
      p.adult = data.adult
      p.aliases = data.also_known_as.join(',')
      p.imdb_id = data.imdb_id
      p.homepage = data.homepage
      p.gender = case data.gender
      when 2
        'Male'
      else
        'Female'
      end
      p.birthplace = data.place_of_birth
    end
  end

end
