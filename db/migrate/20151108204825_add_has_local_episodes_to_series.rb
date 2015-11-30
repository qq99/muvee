class AddHasLocalEpisodesToSeries < ActiveRecord::Migration
  def change
    add_column :series, :has_local_episodes, :boolean
  end
end
