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

  def fetch_data
    return self unless should_query_remote?

    Rails.logger.info "Fetching #{self.endpoint}"
    response = fetch(self.endpoint)

    return self unless response.present?

    self.raw_value = if result_format == :xml
      Hash.from_xml(response).try(:with_indifferent_access) || {}
    elsif result_format == :json
      JSON.parse(response).try(:with_indifferent_access) || {}
    end

    self
  rescue => e
    self.raw_value = {}
    Rails.logger.error "ExternalMetadata#fetch_data failed to parse response: #{e}"
  end

  def data
    self.raw_value || {}
  end
end
