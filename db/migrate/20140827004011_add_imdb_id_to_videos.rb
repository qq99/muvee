class AddImdbIdToVideos < ActiveRecord::Migration
  def change
    add_column :videos, :imdb_id, :string
  end
end
