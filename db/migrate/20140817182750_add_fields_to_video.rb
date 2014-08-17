class AddFieldsToVideo < ActiveRecord::Migration
  def change
    add_column :videos, :released_on, :datetime
    add_column :videos, :language, :string
    add_column :videos, :country, :string
    add_column :videos, :awards, :string
    add_column :videos, :poster_path, :string
  end
end
