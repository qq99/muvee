class ExternalMetadata < ActiveRecord::Base
  include DownloadFile

  validates_uniqueness_of :endpoint
  serialize :raw_value

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

  def should_fetch
    self.updated_at.blank? || (self.updated_at.present? && self.updated_at <= 1.days.ago)
  end

  def fetch_data
    if should_fetch
      http_get = fetch(URI(self.endpoint))
      if http_get.present? && http_get.response.kind_of?(Net::HTTPSuccess)
        self.raw_value = http_get.body.to_s#.encode('UTF-8', {:invalid => :replace, :undef => :replace, :replace => '?'})
        if result_format == :xml
          begin
            self.raw_value = Hash.from_xml(self.raw_value).try(:with_indifferent_access) || {}
          rescue => e
            self.raw_value = {}
            Rails.logger.error "ExternalMetadata#fetch_data for #{self.endpoint} failed: #{e}"
          end
        elsif result_format == :json
          begin
            self.raw_value = JSON.parse(self.raw_value).try(:with_indifferent_access) || {}
          rescue => e
            self.raw_value = {}
            Rails.logger.error "ExternalMetadata#fetch_data for #{self.endpoint} failed: #{e}"
          end
        end
      end
    end
    return should_fetch
  end

  def data
    self.raw_value || {}
  end
end
