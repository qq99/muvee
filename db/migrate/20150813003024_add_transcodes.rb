class AddTranscodes < ActiveRecord::Migration
  def change
    create_table :transcodes do |t|
      t.references :video
      t.string :type
      t.string :status, default: 'pending'
      t.string :raw_file_path
      t.timestamps null: false
      t.index :raw_file_path, unique: true
    end
  end
end
