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

ActiveRecord::Schema.define(version: 20150318224718) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "application_configurations", force: :cascade do |t|
    t.text     "tv_sources",            default: [],    array: true
    t.text     "movie_sources",         default: [],    array: true
    t.string   "transcode_folder"
    t.boolean  "transcode_media",       default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "torrent_start_path"
    t.text     "torrent_complete_path"
  end

  create_table "external_metadata", force: :cascade do |t|
    t.integer  "video_id"
    t.string   "type"
    t.text     "raw_value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "endpoint"
    t.integer  "series_id"
  end

  add_index "external_metadata", ["endpoint"], name: "index_external_metadata_on_endpoint", unique: true, using: :btree

  create_table "fanarts", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "raw_file_path"
    t.integer  "video_id"
  end

  create_table "genres", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "genres_videos", id: false, force: :cascade do |t|
    t.integer "genre_id"
    t.integer "video_id"
  end

  create_table "movies", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "series", force: :cascade do |t|
    t.string   "title"
    t.integer  "tvdb_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tvdb_series_result_id"
    t.text     "overview"
    t.decimal  "tvdb_rating"
    t.integer  "tvdb_rating_count"
    t.string   "status"
    t.integer  "last_watched_video_id"
    t.string   "poster_path"
    t.string   "banner_path"
    t.string   "fanart_path"
    t.integer  "tv_shows_count",        default: 0
  end

  create_table "thumbnails", force: :cascade do |t|
    t.integer  "video_id"
    t.string   "raw_file_path"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "torrents", force: :cascade do |t|
    t.text     "source",          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "transmission_id"
    t.integer  "video_id"
    t.string   "video_type"
  end

  create_table "tv_shows", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tvdb_search_results", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tvdb_series_results", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "videos", force: :cascade do |t|
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
    t.text     "overview"
    t.string   "episode_name"
    t.datetime "released_on"
    t.string   "language"
    t.string   "country"
    t.string   "awards"
    t.string   "poster_path"
    t.integer  "year"
    t.string   "quality"
    t.boolean  "is_3d"
    t.string   "type_of_3d"
    t.string   "status"
    t.string   "imdb_id"
    t.string   "transmission_id"
    t.boolean  "imdb_id_is_accurate"
    t.text     "tagline"
    t.integer  "vote_count"
    t.decimal  "vote_average"
    t.string   "parental_guidance_rating"
    t.integer  "runtime_minutes"
  end

  add_index "videos", ["raw_file_path"], name: "index_videos_on_raw_file_path", unique: true, using: :btree

end
