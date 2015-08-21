class AddActors < ActiveRecord::Migration
  def change
    create_table :actors do |t|
      t.references :video
      t.string :name
      t.timestamps null: false
      t.index :name, unique: true
    end

    create_table :actors_videos do |t|
      t.references :video
      t.references :actor
    end
  end

  # def down
  #   drop_table :actors
  #   drop_table :actors_videos
  #   drop_table :videos_actors
  # end
end
