class AddFieldsToSeries < ActiveRecord::Migration
  def change
    add_column :series, :last_sort_value, :string
    add_column :series, :last_season_filter, :string
  end
end
