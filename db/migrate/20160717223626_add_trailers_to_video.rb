class AddTrailersToVideo < ActiveRecord::Migration[5.0]
  def change
    create_table :trailers do |t|
      t.references :video
      t.string :name
      t.string :youtube_id
      t.timestamps
    end

    add_index :trailers, :youtube_id, unique: true
  end
end
