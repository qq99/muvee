class Series < ActiveRecord::Base
  has_many :tv_shows

  def series_search
    @search_result ||= TvdbSearchResult.get(self.title)
  end

  def series_metadata
    @series_metadata = series_search.data_from_xml[:Data][:Series]
  end

  def banner_url
    series_metadata[:banner]
  end

  def overview
    series_metadata[:Overview]
  end

  def first_aired
    series_metadata[:FirstAired]
  end

  def network
    series_metadata[:Network]
  end

  def IMDB_id
    series_metadata[:IMDB_ID]
  end
end
