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
