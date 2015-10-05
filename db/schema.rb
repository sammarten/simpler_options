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

ActiveRecord::Schema.define(version: 20151005174301) do

  create_table "exchanges", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "symbol",     limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "quotes", id: false, force: :cascade do |t|
    t.integer  "id",          limit: 8
    t.datetime "time"
    t.date     "date"
    t.string   "period",      limit: 255
    t.decimal  "open",                    precision: 10
    t.decimal  "high",                    precision: 10
    t.decimal  "low",                     precision: 10
    t.decimal  "close",                   precision: 10
    t.integer  "volume",      limit: 8
    t.integer  "security_id", limit: 4
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "quotes", ["date", "period", "security_id"], name: "index_quotes_on_date_and_period_and_security_id", using: :btree
  add_index "quotes", ["security_id"], name: "index_quotes_on_security_id", using: :btree

  create_table "securities", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "symbol",      limit: 255
    t.integer  "exchange_id", limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "securities", ["exchange_id"], name: "index_securities_on_exchange_id", using: :btree

  add_foreign_key "quotes", "securities"
  add_foreign_key "securities", "exchanges"
end
