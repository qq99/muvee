class AddSeriesIdToTvdbSeriesResult < ActiveRecord::Migration
  def change
    add_column :external_metadata, :series_id, :integer
  end
end
