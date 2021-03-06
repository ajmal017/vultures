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

ActiveRecord::Schema.define(version: 20150601215234) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "companies", force: true do |t|
    t.string "name"
    t.string "cid"
    t.string "ticker"
  end

  create_table "price_points", force: true do |t|
    t.string  "cid"
    t.date    "period"
    t.date    "delisting_date"
    t.float   "market_cap"
    t.float   "earnings_yield"
    t.float   "roc"
    t.float   "price"
    t.boolean "delisted"
    t.float   "ltm_ebit"
    t.float   "nwc"
    t.float   "ev"
    t.float   "net_ppe"
  end

  create_table "results", force: true do |t|
    t.text     "result_string"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
