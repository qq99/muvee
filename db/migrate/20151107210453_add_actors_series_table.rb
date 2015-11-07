class AddActorsSeriesTable < ActiveRecord::Migration
  def change
    create_table :actors_series do |t|
      t.references :series
      t.references :actor
    end
  end
end
