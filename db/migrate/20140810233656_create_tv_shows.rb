class CreateTvShows < ActiveRecord::Migration
  def change
    create_table :tv_shows do |t|

      t.timestamps
    end
  end
end
