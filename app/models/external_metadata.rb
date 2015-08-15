class ExternalMetadata < ActiveRecord::Base
  include DownloadFile

  validates_uniqueness_of :endpoint
  serialize :raw_value

  def self.get(*args)
    escaped_args = args.map{|a| CGI.escape(a.to_s)}
    url = self.endpoint_url(*escaped_args)

    result = self.find_or_initialize_by(endpoint: url)
    result.fetch_data
    result.save if result.changed?
    result
  end

  def staleness_factor
    6.hours.ago
  end

  def should_query_remote?
    last_touched = updated_at.presence || created_at.presence
    never_touched = last_touched.blank?

    never_touched || (last_touched <= staleness_factor) || saved_nil_data?
  end

  def saved_nil_data?
    self.raw_value.blank?
  end

  def query_remote(uri)
    fetch(uri.to_s)
  end

  def fetch_data
    if should_query_remote?
      Rails.logger.info "Fetching #{self.endpoint}"
      http_get = query_remote(URI.parse(self.endpoint))
      if http_get.present? && http_get.response.kind_of?(Net::HTTPSuccess)
        Rails.logger.info "Fetched #{self.endpoint}"
        self.raw_value = http_get.body.to_s#.encode('UTF-8', {:invalid => :replace, :undef => :replace, :replace => '?'})
        if result_format == :xml
          begin
            self.raw_value = Hash.from_xml(self.raw_value).try(:with_indifferent_access) || {}
          rescue => e
            self.raw_value = {}
            Rails.logger.error "ExternalMetadata#fetch_data as XML for #{self.endpoint} failed: #{e}"
          end
        elsif result_format == :json
          begin
            self.raw_value.try(:gsub!, "\"Type\":\"movie,", '') # fix for OMDB, really hacky that it's in here
            self.raw_value = JSON.parse(self.raw_value).try(:with_indifferent_access) || {}
          rescue => e
            self.raw_value = {}
            Rails.logger.error "ExternalMetadata#fetch_data as JSON for #{self.endpoint} failed: #{e}"
          end
        end
      end
    end

    self
  end

  def data
    self.raw_value || {}
  end
end
