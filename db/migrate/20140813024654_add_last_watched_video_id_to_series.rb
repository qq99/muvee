class AddLastWatchedVideoIdToSeries < ActiveRecord::Migration
  def change
    add_column :series, :last_watched_video_id, :integer
  end
end
