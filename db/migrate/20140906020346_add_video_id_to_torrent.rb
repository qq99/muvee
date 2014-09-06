class AddVideoIdToTorrent < ActiveRecord::Migration
  def change
    add_column :torrents, :video_id, :integer
  end
end
