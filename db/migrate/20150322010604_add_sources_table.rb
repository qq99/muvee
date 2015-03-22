class AddSourcesTable < ActiveRecord::Migration
  def change
    create_table :sources do |t|
      t.belongs_to :video
      t.string   "type"
      t.string   "raw_file_path", null: false
      t.string   "quality"
      t.boolean  "is_3d"
      t.string   "type_of_3d"
      t.timestamps
    end

    add_index :sources, [:raw_file_path], unique: true
  end
end
