class Add3DFieldsToVideos < ActiveRecord::Migration
  def change
    add_column :videos, :is_3d, :boolean
    add_column :videos, :type_of_3d, :string
  end
end
