# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140813024654) do

  create_table "external_metadata", force: true do |t|
    t.integer  "video_id"
    t.string   "type"
    t.text     "raw_value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "endpoint"
    t.integer  "series_id"
  end

  add_index "external_metadata", ["endpoint"], name: "index_external_metadata_on_endpoint", unique: true

  create_table "movies", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "series", force: true do |t|
    t.string   "title"
    t.integer  "tvdb_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tvdb_series_result_id"
    t.string   "overview"
    t.decimal  "tvdb_rating"
    t.integer  "tvdb_rating_count"
    t.string   "status"
    t.integer  "last_watched_video_id"
  end

  create_table "thumbnails", force: true do |t|
    t.integer  "video_id"
    t.string   "raw_file_path"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tv_shows", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tvdb_search_results", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tvdb_series_results", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "videos", force: true do |t|
    t.string   "raw_file_path"
    t.string   "type"
    t.integer  "episode"
    t.integer  "season"
    t.integer  "duration"
    t.integer  "left_off_at"
    t.integer  "series_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.string   "overview"
    t.string   "video"
    t.string   "episode_name"
  end

end
