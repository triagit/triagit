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

ActiveRecord::Schema.define(version: 20170620221619) do

  create_table "accounts", force: :cascade do |t|
    t.string "token"
    t.string "name"
    t.string "service"
    t.string "plan"
    t.string "ref"
    t.text "payload"
    t.text "rules"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "events", force: :cascade do |t|
    t.integer "repo_id"
    t.string "name"
    t.string "ref"
    t.text "payload"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["repo_id"], name: "index_events_on_repo_id"
  end

  create_table "repos", force: :cascade do |t|
    t.integer "account_id"
    t.string "name"
    t.string "ref"
    t.text "payload"
    t.text "rules"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_repos_on_account_id"
  end

end
