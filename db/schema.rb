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

ActiveRecord::Schema[8.1].define(version: 2026_05_22_171019) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "athlete_contracts", force: :cascade do |t|
    t.bigint "athlete_id", null: false
    t.bigint "club_id", null: false
    t.datetime "created_at", null: false
    t.boolean "current", default: true, null: false
    t.date "end_date"
    t.boolean "loan", default: false, null: false
    t.decimal "release_clause", precision: 15, scale: 2
    t.integer "squad_number"
    t.date "start_date", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.decimal "wage", precision: 15, scale: 2, default: "0.0", null: false
    t.index ["athlete_id", "current"], name: "index_athlete_contracts_on_athlete_id_and_current", unique: true, where: "current"
    t.index ["athlete_id"], name: "index_athlete_contracts_on_athlete_id"
    t.index ["club_id", "squad_number", "current"], name: "idx_on_club_id_squad_number_current_5d43105888", unique: true, where: "(current AND (squad_number IS NOT NULL))"
    t.index ["club_id"], name: "index_athlete_contracts_on_club_id"
  end

  create_table "athletes", force: :cascade do |t|
    t.integer "acceleration", default: 1, null: false
    t.date "birthdate"
    t.integer "composure", default: 1, null: false
    t.integer "condition", default: 100, null: false
    t.bigint "country_id", null: false
    t.datetime "created_at", null: false
    t.integer "crossing", default: 1, null: false
    t.integer "current_ability", default: 1, null: false
    t.integer "decisions", default: 1, null: false
    t.integer "dribbling", default: 1, null: false
    t.integer "finishing", default: 1, null: false
    t.string "first_name", null: false
    t.integer "first_touch", default: 1, null: false
    t.integer "heading", default: 1, null: false
    t.integer "height_cm"
    t.integer "jumping", default: 1, null: false
    t.string "last_name", null: false
    t.integer "long_shots", default: 1, null: false
    t.integer "marking", default: 1, null: false
    t.integer "morale", default: 50, null: false
    t.integer "pace", default: 1, null: false
    t.integer "passing", default: 1, null: false
    t.integer "position", default: 0, null: false
    t.integer "positioning", default: 1, null: false
    t.integer "potential_ability", default: 1, null: false
    t.integer "preferred_foot", default: 0, null: false
    t.integer "reputation", default: 1, null: false
    t.integer "stamina", default: 1, null: false
    t.integer "status", default: 0, null: false
    t.integer "strength", default: 1, null: false
    t.integer "tackling", default: 1, null: false
    t.integer "teamwork", default: 1, null: false
    t.integer "technique", default: 1, null: false
    t.datetime "updated_at", null: false
    t.integer "weight_kg"
    t.integer "work_rate", default: 1, null: false
    t.index ["country_id"], name: "index_athletes_on_country_id"
  end

  create_table "careers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "current_date", null: false
    t.string "name", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_careers_on_user_id"
  end

  create_table "club_finances", force: :cascade do |t|
    t.decimal "cash_balance", precision: 15, scale: 2, default: "0.0", null: false
    t.bigint "club_id", null: false
    t.datetime "created_at", null: false
    t.decimal "debt", precision: 15, scale: 2, default: "0.0", null: false
    t.decimal "expenses", precision: 15, scale: 2, default: "0.0", null: false
    t.decimal "prize_money", precision: 15, scale: 2, default: "0.0", null: false
    t.decimal "sponsorship_income", precision: 15, scale: 2, default: "0.0", null: false
    t.decimal "stadium_income", precision: 15, scale: 2, default: "0.0", null: false
    t.decimal "transfer_budget", precision: 15, scale: 2, default: "0.0", null: false
    t.datetime "updated_at", null: false
    t.decimal "wage_budget", precision: 15, scale: 2, default: "0.0", null: false
    t.index ["club_id"], name: "index_club_finances_on_club_id", unique: true
  end

  create_table "clubs", force: :cascade do |t|
    t.bigint "country_id", null: false
    t.datetime "created_at", null: false
    t.integer "founded_year"
    t.boolean "international", default: false, null: false
    t.string "name", null: false
    t.integer "reputation", default: 1, null: false
    t.string "short_name", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["country_id", "name"], name: "index_clubs_on_country_id_and_name", unique: true
    t.index ["country_id"], name: "index_clubs_on_country_id"
  end

  create_table "countries", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "reputation", default: 1, null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_countries_on_code", unique: true
    t.index ["name"], name: "index_countries_on_name", unique: true
  end

  create_table "manager_contracts", force: :cascade do |t|
    t.bigint "club_id", null: false
    t.datetime "created_at", null: false
    t.boolean "current", default: true, null: false
    t.date "end_date"
    t.text "expectations"
    t.bigint "manager_id", null: false
    t.integer "role", default: 0, null: false
    t.date "start_date", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.decimal "wage", precision: 15, scale: 2, default: "0.0", null: false
    t.index ["club_id", "current"], name: "index_manager_contracts_on_club_id_and_current", unique: true, where: "current"
    t.index ["club_id"], name: "index_manager_contracts_on_club_id"
    t.index ["manager_id", "current"], name: "index_manager_contracts_on_manager_id_and_current", unique: true, where: "current"
    t.index ["manager_id"], name: "index_manager_contracts_on_manager_id"
  end

  create_table "managers", force: :cascade do |t|
    t.date "birthdate"
    t.bigint "career_id", null: false
    t.bigint "country_id", null: false
    t.datetime "created_at", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.integer "reputation", default: 1, null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["career_id"], name: "index_managers_on_career_id", unique: true
    t.index ["country_id"], name: "index_managers_on_country_id"
    t.index ["user_id"], name: "index_managers_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "stadiums", force: :cascade do |t|
    t.integer "capacity", default: 0, null: false
    t.string "city", null: false
    t.bigint "club_id", null: false
    t.bigint "country_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "ownership", default: 0, null: false
    t.integer "pitch_quality", default: 1, null: false
    t.datetime "updated_at", null: false
    t.index ["club_id"], name: "index_stadiums_on_club_id"
    t.index ["country_id", "name"], name: "index_stadiums_on_country_id_and_name", unique: true
    t.index ["country_id"], name: "index_stadiums_on_country_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "athlete_contracts", "athletes"
  add_foreign_key "athlete_contracts", "clubs"
  add_foreign_key "athletes", "countries"
  add_foreign_key "careers", "users"
  add_foreign_key "club_finances", "clubs"
  add_foreign_key "clubs", "countries"
  add_foreign_key "manager_contracts", "clubs"
  add_foreign_key "manager_contracts", "managers"
  add_foreign_key "managers", "careers"
  add_foreign_key "managers", "countries"
  add_foreign_key "managers", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "stadiums", "clubs"
  add_foreign_key "stadiums", "countries"
end
