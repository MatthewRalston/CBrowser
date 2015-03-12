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

ActiveRecord::Schema.define(version: 20150306165724) do

  create_table "coverages", force: :cascade do |t|
    t.string   "chr",        limit: 255
    t.integer  "base",       limit: 4
    t.string   "stress",     limit: 255
    t.string   "time",       limit: 255
    t.string   "rep",        limit: 255
    t.string   "strand",     limit: 255
    t.integer  "cov",        limit: 4
    t.integer  "tex",        limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "coverages", ["base"], name: "index_coverages_on_base", using: :btree

  create_table "genomeannotations", force: :cascade do |t|
    t.string   "chr",        limit: 255
    t.string   "name",       limit: 255
    t.string   "author",     limit: 255
    t.string   "feature",    limit: 255
    t.integer  "start_site", limit: 4
    t.integer  "stop_site",  limit: 4
    t.string   "strand",     limit: 255
    t.string   "technique",  limit: 255
    t.string   "journal",    limit: 255
    t.date     "date"
    t.string   "extra",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
