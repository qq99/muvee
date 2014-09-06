class AddVideoTypeToTorrent < ActiveRecord::Migration
  def change
    add_column :torrents, :video_type, :string
  end
end
