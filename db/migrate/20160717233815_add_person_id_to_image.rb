class AddPersonIdToImage < ActiveRecord::Migration[5.0]
  def change
    add_column :images, :person_id, :integer
  end
end
