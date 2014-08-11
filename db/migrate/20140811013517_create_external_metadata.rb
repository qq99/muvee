class CreateExternalMetadata < ActiveRecord::Migration
  def change
    create_table :external_metadata do |t|
      t.integer :video_id
      t.string :type
      t.string :raw_value

      t.timestamps
    end
  end
end
