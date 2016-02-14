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

  def fetch(uri_str)
    begin
      response = ExternalMetadataRequest.get(uri_str)
      response
    rescue
      nil
    end
  end

end
