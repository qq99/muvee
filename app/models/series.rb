class Series < ActiveRecord::Base
  include HasMetadata

  has_many :tv_shows

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
