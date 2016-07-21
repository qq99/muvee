class AddTmdbRatingsToSeries < ActiveRecord::Migration[5.0]
  def change
    add_column :series, :tmdb_vote_average, :float
    add_column :series, :tmdb_vote_count, :integer
  end
end
