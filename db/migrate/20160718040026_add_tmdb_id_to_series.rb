class AddTmdbIdToSeries < ActiveRecord::Migration[5.0]
  def change
    add_column :series, :tmdb_id, :string
  end
end
