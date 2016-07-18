class AddDefaultHasLocalEpisodesFalse < ActiveRecord::Migration[5.0]
  def change
    change_column :series, :has_local_episodes, :boolean, default: false
  end
end
