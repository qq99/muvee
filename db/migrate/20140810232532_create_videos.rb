class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.string :raw_file_path
      t.string :type
      t.integer :episode
      t.integer :season
      t.integer :duration
      t.integer :left_off_at
      t.integer :series_id

      t.timestamps
    end
  end
end
