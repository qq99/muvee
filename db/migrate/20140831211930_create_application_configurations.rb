class CreateApplicationConfigurations < ActiveRecord::Migration
  def change
    create_table :application_configurations do |t|
      t.text :tv_sources, array: true, default: []
      t.text :movie_sources, array: true, default: []
      t.string :transcode_folder
      t.boolean :transcode_media, default: false
      t.timestamps
    end
  end
end
