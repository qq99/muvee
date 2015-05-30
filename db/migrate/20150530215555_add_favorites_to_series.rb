class AddFavoritesToSeries < ActiveRecord::Migration
  def change
    add_column :series, :is_favorite, :boolean, default: false
  end
end
