class AddEpisodeNameToVideo < ActiveRecord::Migration
  def change
    add_column :videos, :episode_name, :string
  end
end
