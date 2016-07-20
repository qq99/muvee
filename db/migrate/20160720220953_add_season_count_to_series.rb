class AddSeasonCountToSeries < ActiveRecord::Migration[5.0]
  def change
    add_column :series, :seasons_count, :integer, default: 0
  end
end
