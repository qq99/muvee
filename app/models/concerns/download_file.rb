module DownloadFile

  def download_file(remote_path, output_filename)
    return unless remote_path.present? && output_filename.present?

    begin
      f = open(output_filename, "wb")
      response = fetch(remote_path)
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

  def fetch(uri_str, limit = 5)
    raise ArgumentError, 'too many HTTP redirects' if limit == 0

    begin
      Net::HTTP.read_timeout = 5 # 5 seconds sounds reasonable
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

end
