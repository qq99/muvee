class CreateMovies < ActiveRecord::Migration
  def change
    create_table :movies do |t|

      t.timestamps
    end
  end
end
