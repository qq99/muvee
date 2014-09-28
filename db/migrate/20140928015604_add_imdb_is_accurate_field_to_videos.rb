class AddImdbIsAccurateFieldToVideos < ActiveRecord::Migration
  def change
    add_column :videos, :imdb_id_is_accurate, :boolean
  end
end
