class AddTvdbSeriesResultIdToSeries < ActiveRecord::Migration
  def change
    add_column :series, :tvdb_series_result_id, :integer
  end
end
