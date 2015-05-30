module HasMetadata
  def self.included(base)
    base.class_eval do
      def all_episodes_metadata
        @all_episodes_metadata ||= episode_metadata_search.data.fetch(:Data, {}).try(:fetch, :Episode, {})
      end

      def series_metadata
        @series_metadata ||= episode_metadata_search.data.fetch(:Data, {}).try(:fetch, :Series, {})
      end

      def episode_metadata_search
        tvdb_id = self.try(:tvdb_id).presence || metadata[:seriesid]
        @episode_metadata_search ||= TvdbSeriesResult.get(tvdb_id)
      end

      def episode_specific_metadata
        episode_metadata = all_episodes_metadata

        if episode_metadata.kind_of? Hash
          episode_metadata = [episode_metadata]
        end

        @meta ||= episode_metadata.select { |e|
          e[:SeasonNumber].to_i == season &&
          e[:EpisodeNumber].to_i == episode
        }.first || {}
      end

      def metadata(title = nil)
        @metadata ||= get_first_series_data_matching_title(title || self.title) || {}
      end

      private

      def get_first_series_data_matching_title(title)
        return {} unless title.present?

        @series_search ||= TvdbSearchResult.get(title)

        results = @series_search.data.fetch(:Data, {}).try(:fetch, :Series, nil)
        if results.kind_of? Array
          return results.first
        elsif results.kind_of? Hash
          return results
        end
      end
    end
  end
end
