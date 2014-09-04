class AddGenresVideosTable < ActiveRecord::Migration
  def change
    create_table :genres_videos, id: false do |t|
      t.belongs_to :genre
      t.belongs_to :video
    end
  end
end
