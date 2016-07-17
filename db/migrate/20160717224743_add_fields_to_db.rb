class AddFieldsToDb < ActiveRecord::Migration[5.0]
  def change
    add_column :videos, :popularity, :float
    add_column :videos, :mpaa_rating, :string
    add_column :videos, :website, :string
    add_column :videos, :tmdb_id, :string
    add_column :videos, :tvdb_id, :string
    add_column :videos, :omdb_id, :string
    add_column :videos, :budget, :integer
    add_column :videos, :revenue, :integer
    add_column :videos, :adult, :boolean

    create_table "people" do |t|
      t.string   "imdb_id"
      t.string   "tmdb_id"
      t.string   "tvdb_id"
      t.string   "full_name"
      t.text     "biography"
      t.string   "homepage"
      t.string   "birthplace"
      t.date     "birthday"
      t.date     "deathday"
      t.text     "aliases"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "people_series" do |t|
      t.integer "series_id"
      t.integer "person_id"
    end

    create_table "people_videos" do |t|
      t.integer "video_id"
      t.integer "person_id"
    end

    create_table "roles" do |t|
      t.integer "person_id"
      t.integer "video_id"
      t.string  "department"
      t.string  "job_title"
      t.string  "character"
    end

    create_table "images" do |t|
      t.integer  "video_id"
      t.integer  "series_id"
      t.string   "type"
      t.string   "path"
      t.float    "aspect_ratio"
      t.integer  "height"
      t.integer  "width"
      t.string   "language"
      t.float    "vote_average"
      t.integer  "vote_count"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

  end
end
