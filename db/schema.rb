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

ActiveRecord::Schema[8.0].define(version: 2026_09_01_120000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"
  enable_extension "unaccent"

  create_table "medicament_managements", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "medicament_id", null: false
    t.uuid "patient_id", null: false
    t.integer "quantity"
    t.string "unit_quantity"
    t.string "via"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "medicaments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "fullname"
  end

  create_table "patients", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "diagnosis"
    t.string "sus"
    t.string "rg"
    t.string "cpf"
    t.date "admission_date"
    t.date "birth_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "photo_url"
    t.string "firstname"
    t.string "lastname"
    t.string "photo_key"
    t.string "gender"
    t.string "status", default: "active"
  end

  create_table "refresh_tokens", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "token_digest", null: false
    t.datetime "expires_at", null: false
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token_digest"], name: "index_refresh_tokens_on_token_digest", unique: true
    t.index ["user_id"], name: "index_refresh_tokens_on_user_id"
  end

  create_table "shift_item_checks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "shift_id", null: false
    t.uuid "shift_item_id", null: false
    t.boolean "checked", default: false, null: false
    t.uuid "checked_by_id"
    t.datetime "checked_at"
    t.boolean "impossible", default: false, null: false
    t.text "impossible_reason"
    t.string "review_status", default: "pending", null: false
    t.uuid "reviewed_by_id"
    t.datetime "reviewed_at"
    t.text "divergence_note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shift_id", "shift_item_id"], name: "index_shift_item_checks_on_shift_id_and_shift_item_id", unique: true
  end

  create_table "shift_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_shift_items_on_name", unique: true
  end

  create_table "shifts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.date "shift_date", null: false
    t.string "shift_type", null: false
    t.string "status", default: "open", null: false
    t.text "execution_note"
    t.datetime "execution_finalized_at"
    t.uuid "execution_finalized_by_id"
    t.datetime "review_finalized_at"
    t.uuid "review_finalized_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.index ["shift_date", "shift_type"], name: "index_shifts_on_shift_date_and_shift_type"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "login", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "group", null: false
    t.boolean "active", default: true, null: false
    t.boolean "must_change_password", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["login"], name: "index_users_on_login", unique: true
  end

  create_table "visitors", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "lastname"
    t.text "firstname"
  end

  create_table "visits", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "patient_id", null: false
    t.uuid "visitor_id", null: false
    t.datetime "start_date", null: false
    t.datetime "end_date", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "canceled", default: false
  end

  create_table "vital_signs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "patient_id", null: false
    t.string "pa"
    t.string "period"
    t.integer "bpm"
    t.integer "saturation"
    t.string "blood_glucose"
    t.float "temperature"
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "diuresis"
    t.string "feces"
  end

  add_foreign_key "refresh_tokens", "users"
  add_foreign_key "shift_item_checks", "shift_items"
  add_foreign_key "shift_item_checks", "shifts"
  add_foreign_key "shift_item_checks", "users", column: "checked_by_id"
  add_foreign_key "shift_item_checks", "users", column: "reviewed_by_id"
  add_foreign_key "shifts", "users", column: "execution_finalized_by_id"
  add_foreign_key "shifts", "users", column: "review_finalized_by_id"
end
