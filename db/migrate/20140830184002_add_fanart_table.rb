class AddFanartTable < ActiveRecord::Migration
  def change
    create_table :fanart do |t|
      t.integer  "video_id"
      t.string   "raw_file_path"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
