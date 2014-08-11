class ExternalMetadata < ActiveRecord::Base
  validates_uniqueness_of :endpoint

  def fetch(uri_str, limit = 10)
    raise ArgumentError, 'too many HTTP redirects' if limit == 0

    response = Net::HTTP.get_response(URI(uri_str))

    case response
    when Net::HTTPSuccess then
      response
    when Net::HTTPRedirection then
      location = response['location']
      warn "redirected to #{location}"
      fetch(location, limit - 1)
    else
      response.value
    end
  end

  def self.get(*args)
    escaped_args = args.map{|a| CGI.escape(a)}
    url = self.endpoint_url(*escaped_args)

    result = self.find_by_endpoint(url)
    if !result
      result = self.new
      result.endpoint = url
      result.save
    end
    result.fetch_data
    result
  end

  def fetch_data
    should_fetch = !self.updated_at || (self.updated_at > 1.days.ago)
    if should_fetch
      http_get = fetch(URI(self.endpoint))
      if http_get.response.kind_of? Net::HTTPSuccess
        self.raw_value = http_get.body
      end
      save
    end
  end
end
