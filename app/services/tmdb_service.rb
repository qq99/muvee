require 'faraday'
require 'typhoeus'
require 'typhoeus/adapters/faraday'

class TmdbService

  def get_data
    response = perform_request

    data = case response.status
    when 200
      Hashie::Mash.new(JSON.parse(response.body.force_encoding('utf-8')))
    when 429
      raise Exceptions::TmdbError.new("Rate limit exceeded")
    else
      raise Exceptions::TmdbError.new("Something went wrong: #{response.body}")
    end

    raise Exceptions::TmdbError.new(data.status_message) if data.status_message.present?

    data
  end

  def quick_create_movies(data)
    movies = data.results || []

    movies.map do |datum|
      m = Movie.find_by(tmdb_id: datum.id)
      return if m.present?

      m = Movie.new
      m.tmdb_id = datum.id
      m.adult = datum.adult
      m.title = datum.title
      m.overview = datum.overview

      m.save
      m.reanalyze
      m
    end
  end

  def quick_create_series(data)
    series = data.results || []

    series.map do |datum|
      s = Series.find_by(tmdb_id: datum.id)
      return if s.present?

      s = Series.new
      s.tmdb_id = datum.id
      s.title = datum.name
      s.overview = datum.overview

      s.save
      s.reanalyze
      s
    end
  end

  def perform_request
    client = Faraday.new do |faraday|
      faraday.use :http_cache, store: Rails.cache, logger: Rails.logger, serializer: Marshal
      faraday.adapter :typhoeus
    end

    client.get url,
      followlocation: true,
      accept_encoding: "gzip"
  end

end
