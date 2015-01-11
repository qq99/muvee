class AddUniqueIndexToVideos < ActiveRecord::Migration
  def change
    add_index :videos, [:raw_file_path], unique: true
  end
end
