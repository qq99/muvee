class AddSourcedAtColumnToVideo < ActiveRecord::Migration
  def change
    add_column :videos, :sourced_at, :timestamp
  end
end
