class TmdbImageResult < ExternalMetadata

  def result_format
    :json
  end

  def self.endpoint_url(tmdb_id)
    "https://api.themoviedb.org/3/movie/#{tmdb_id}/images?api_key=#{Figaro.env.tmdb_api_key}&language=en&include_image_language=en,null"
  end

end
