class TmdbSeriesSearchingService < TmdbService
  def initialize(title)
    raise ArgumentError.new("You must supply a title") unless title.present?
    @title = title
  end

  def run
    data = expanded_get_data
    results = data.results || []
    results.first.try(:id)
  end

  def expanded_get_data
    data = get_data

    if data.results_.blank?
      altered_title = @title.gsub(/(\(\d{4}\))/, '')
      if altered_title != @title
        @title = altered_title
        data = get_data
      end
    end

    data
  end

  def search_and_create
    data = expanded_get_data
    quick_create_series(data)
  end

  private

  def title
    @title
  end

  def url
    "https://api.themoviedb.org/3/search/tv?api_key=#{Figaro.env.tmdb_api_key}&query=#{URI::encode(title)}"
  end
end
