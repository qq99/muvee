class AddSeriesIdToRole < ActiveRecord::Migration[5.0]
  def change
    add_column :roles, :series_id, :integer
  end
end
