class AddGenresSeriesTable < ActiveRecord::Migration
  def change
    def change
      create_table :genres_series do |t|
        t.references :genre
        t.references :series
      end
    end
  end
end
