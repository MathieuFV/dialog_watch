# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_01_11_194557) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "daily_snapshots", force: :cascade do |t|
    t.date "date"
    t.integer "total_organizations"
    t.integer "total_regulations"
    t.integer "added_regulations"
    t.integer "removed_regulations"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_organizations_on_name", unique: true
  end

  create_table "regulations", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.string "external_id"
    t.string "regulation_type"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "last_seen_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "regulation_id"
    t.boolean "active", default: true, null: false
    t.index ["external_id"], name: "index_regulations_on_external_id", unique: true
    t.index ["organization_id"], name: "index_regulations_on_organization_id"
  end

  create_table "restrictions", force: :cascade do |t|
    t.bigint "regulation_id", null: false
    t.string "restriction_type"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["regulation_id"], name: "index_restrictions_on_regulation_id"
  end

  create_table "snapshot_events", force: :cascade do |t|
    t.bigint "daily_snapshot_id", null: false
    t.bigint "organization_id", null: false
    t.bigint "regulation_id", null: false
    t.string "event_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["daily_snapshot_id"], name: "index_snapshot_events_on_daily_snapshot_id"
    t.index ["organization_id"], name: "index_snapshot_events_on_organization_id"
    t.index ["regulation_id"], name: "index_snapshot_events_on_regulation_id"
  end

  add_foreign_key "regulations", "organizations"
  add_foreign_key "restrictions", "regulations"
  add_foreign_key "snapshot_events", "daily_snapshots"
  add_foreign_key "snapshot_events", "organizations"
  add_foreign_key "snapshot_events", "regulations"
end
