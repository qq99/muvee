class AddFieldsToPerson < ActiveRecord::Migration[5.0]
  def change
    add_column :people, :adult, :boolean
    add_column :people, :gender, :string
    add_column :people, :popularity, :float
  end
end
