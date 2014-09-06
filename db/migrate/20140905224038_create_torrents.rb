class CreateTorrents < ActiveRecord::Migration
  def change
    create_table :torrents do |t|
      t.text :source, null: false
      t.text :raw_file_path, null: false
      t.timestamps
    end
  end
end
