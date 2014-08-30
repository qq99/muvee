class CreateFanarts < ActiveRecord::Migration
  def change
    create_table :fanarts do |t|

      t.timestamps
    end
  end
end
