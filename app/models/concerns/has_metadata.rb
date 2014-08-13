module HasMetadata
  def self.included(base)
    base.class_eval do
      # memoized hashes
      def metadata
        @metadata ||= get_first_series_metadata || {}
      end

      def all_episodes_metadata
        @all_episodes_metadata ||= episode_metadata_search.data.fetch(:Data, {}).try(:fetch, :Episode, {})
      end

      def series_metadata
        @series_metadata ||= episode_metadata_search.data.fetch(:Data, {}).try(:fetch, :Series, {})
      end

      # memoized searches:
      def series_search
        @series_search ||= TvdbSearchResult.get(self.title)
      end

      def episode_metadata_search
        @episode_metadata_search ||= self.try(:tvdb_series_result) || TvdbSeriesResult.get(metadata[:seriesid])
      end



      # episode specific metadata:
      def episode_specific_metadata
        @meta ||= all_episodes_metadata.select{|e| e[:SeasonNumber].to_i == season && e[:EpisodeNumber].to_i == episode}.first || {}
      end

      private

      def get_first_series_metadata
        results = series_search.data.fetch(:Data, {}).try(:fetch, :Series, nil)
        if results.kind_of? Array
          return results.first
        elsif results.kind_of? Hash
          return results
        end
      end
    end
  end
end
