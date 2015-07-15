class AddIsFavoriteToVideos < ActiveRecord::Migration
  def change
    add_column :videos, :is_favorite, :boolean, default: false
  end
end
