class AddTransmissionIdToTorrents < ActiveRecord::Migration
  def change
    add_column :torrents, :transmission_id, :integer
  end
end
