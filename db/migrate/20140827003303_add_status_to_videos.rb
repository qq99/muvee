class AddStatusToVideos < ActiveRecord::Migration
  def change
    add_column :videos, :status, :string
  end
end
