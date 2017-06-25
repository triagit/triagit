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

ActiveRecord::Schema.define(version: 20170625185845) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"
  enable_extension "pgcrypto"

  create_table "account_users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id"
    t.uuid "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_account_users_on_account_id"
    t.index ["user_id", "account_id"], name: "index_account_users_on_user_id_and_account_id", unique: true
    t.index ["user_id"], name: "index_account_users_on_user_id"
  end

  create_table "accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "token", null: false
    t.string "name", null: false
    t.string "service", limit: 2, null: false
    t.string "plan", limit: 4, null: false
    t.string "ref", null: false
    t.text "payload", null: false
    t.text "rules"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", limit: 2, default: 0, null: false
    t.index ["service", "ref"], name: "index_accounts_on_service_and_ref", unique: true
    t.index ["service"], name: "index_accounts_on_service"
    t.index ["status"], name: "index_accounts_on_status"
  end

  create_table "events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "repo_id"
    t.string "name", null: false
    t.string "ref", null: false
    t.text "payload", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", limit: 2, default: 0, null: false
    t.index ["repo_id"], name: "index_events_on_repo_id"
    t.index ["status"], name: "index_events_on_status"
  end

  create_table "repos", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id"
    t.string "name", null: false
    t.string "service", limit: 2, null: false
    t.string "ref", null: false
    t.text "payload", null: false
    t.text "rules"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", limit: 2, default: 0, null: false
    t.index ["account_id"], name: "index_repos_on_account_id"
    t.index ["service", "ref"], name: "index_repos_on_service_and_ref", unique: true
    t.index ["service"], name: "index_repos_on_service"
    t.index ["status"], name: "index_repos_on_status"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "service", limit: 2, null: false
    t.string "ref", null: false
    t.string "payload", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", limit: 2, default: 0, null: false
    t.index ["service", "ref"], name: "index_users_on_service_and_ref", unique: true
    t.index ["service"], name: "index_users_on_service"
    t.index ["status"], name: "index_users_on_status"
  end

  add_foreign_key "account_users", "accounts"
  add_foreign_key "account_users", "users"
  add_foreign_key "events", "repos"
  add_foreign_key "repos", "accounts"
end
