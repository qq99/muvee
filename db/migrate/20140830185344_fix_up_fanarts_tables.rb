class FixUpFanartsTables < ActiveRecord::Migration
  def change
    drop_table :fanart
    add_column :fanarts, :raw_file_path, :string
    add_column :fanarts, :video_id, :integer
  end
end
