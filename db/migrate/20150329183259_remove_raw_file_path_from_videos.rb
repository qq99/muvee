class RemoveRawFilePathFromVideos < ActiveRecord::Migration
  def change
    remove_column :videos, :raw_file_path
  end
end
