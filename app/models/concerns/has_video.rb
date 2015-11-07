module HasVideo
  extend ActiveSupport::Concern

  included do
    def self.has_videos(through:)
      has_many :videos, through: through
      has_many :movies, -> { where(videos: {type: 'Movie'}) }, through: through, source: :video
      has_many :tv_shows, -> { where(videos: {type: 'TvShow'}) }, through: through, source: :video
    end

    def has_movies?
      movies.count > 0
    end

    def has_local_movies?
      movies.local.count > 0
    end

    def has_series?
      series.count > 0
    end

    def has_tv_shows?
      tv_shows.count > 0
    end

    def has_local_tv_shows?
      tv_shows.local.count > 0
    end
  end
end
