class AddTorrentLocationsToApplicationConfiguration < ActiveRecord::Migration
  def change
    add_column :application_configurations, :torrent_start_path, :text
    add_column :application_configurations, :torrent_complete_path, :text
  end
end
