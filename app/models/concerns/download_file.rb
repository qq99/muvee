module DownloadFile

  def download_file(remote_path, output_filename)
    return unless remote_path.present? && output_filename.present?

    begin
      f = open(output_filename, "wb")
      response = fetch_file(remote_path)
      begin
        f.write(response.body)
      ensure
        f.close()
      end
    rescue => e
      Rails.logger.error "Could not download #{remote_path}: #{e}"
      return false
    end
    true
  end

  # TODO: rewrite this!
  def fetch_file(uri_str, limit = 5)
    begin
      response = Net::HTTP.get_response(URI(uri_str))

      case response
      when Net::HTTPSuccess then
        response
      when Net::HTTPRedirection then
        location = response['location']
        warn "redirected to #{location}"
        fetch_file(location, limit - 1)
      else
        response.value
      end
    end
  end

  def fetch(uri_str)
    begin
      response = ExternalMetadataRequest.get(uri_str)
      response.body
    rescue
      nil
    end
  end

end
