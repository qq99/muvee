class AddUniqueIndexForSeriesSeasonEpisode < ActiveRecord::Migration
  def change
    add_index :videos, [:series_id, :season, :episode], unique: true  
  end
end
