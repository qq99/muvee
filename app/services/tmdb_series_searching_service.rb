class TmdbSeriesSearchingService < TmdbService
  def initialize(title)
    raise ArgumentError.new("You must supply a title") unless title.present?
    @title = title
  end

  def run
    data = get_data

    if data.results_.blank?
      altered_title = @title.gsub(/(\(\d{4}\))/, '')
      if altered_title != @title
        @title = altered_title
        data = get_data
      end
    end

    results = data.results || []
    results.first.try(:id)
  end

  private

  def title
    @title
  end

  def url
    "https://api.themoviedb.org/3/search/tv?api_key=#{Figaro.env.tmdb_api_key}&query=#{URI::encode(title)}"
  end
end
