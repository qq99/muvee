class AddUniquenessIndexToGenres < ActiveRecord::Migration[5.0]
  def change
    add_index :genres, :name, unique: true
  end
end
