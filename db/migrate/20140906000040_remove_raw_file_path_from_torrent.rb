class RemoveRawFilePathFromTorrent < ActiveRecord::Migration
  def change
    remove_column :torrents, :raw_file_path
  end
end
