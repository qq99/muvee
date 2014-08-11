class CreateTvdbSeriesResults < ActiveRecord::Migration
  def change
    create_table :tvdb_series_results do |t|

      t.timestamps
    end
  end
end
