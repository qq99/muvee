class ExternalMetadata < ActiveRecord::Base
  validates_uniqueness_of :endpoint
  serialize :raw_value

  def fetch(uri_str, limit = 5)
    raise ArgumentError, 'too many HTTP redirects' if limit == 0

    begin
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
    rescue
      nil
    end
  end

  def self.get(*args)
    escaped_args = args.map{|a| CGI.escape(a.to_s)}
    url = self.endpoint_url(*escaped_args)

    result = self.find_by_endpoint(url)
    if !result
      result = self.new
      result.endpoint = url
    end
    if fetched = result.fetch_data
      result.save
    end
    result
  end

  def fetch_data
    should_fetch = self.updated_at.blank? || (self.updated_at.present? && self.updated_at <= 1.days.ago)
    if should_fetch
      http_get = fetch(URI(self.endpoint))
      if http_get.present? && http_get.response.kind_of?(Net::HTTPSuccess)
        self.raw_value = http_get.body.to_s#.encode('UTF-8', {:invalid => :replace, :undef => :replace, :replace => '?'})
        if result_format == :xml
          self.raw_value = Hash.from_xml(self.raw_value).try(:with_indifferent_access) || {}
        elsif result_format == :json
          self.raw_value = JSON.parse(self.raw_value).try(:with_indifferent_access) || {}
        end
      end
    end
    return should_fetch
  end

  def data
    self.raw_value || {}
  end
end
