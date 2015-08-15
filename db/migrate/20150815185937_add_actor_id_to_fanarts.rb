class AddActorIdToFanarts < ActiveRecord::Migration
  def change
    add_column :fanarts, :actor_id, :integer
  end
end
