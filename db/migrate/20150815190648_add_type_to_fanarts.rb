class AddTypeToFanarts < ActiveRecord::Migration
  def change
    add_column :fanarts, :type, :string
  end
end
