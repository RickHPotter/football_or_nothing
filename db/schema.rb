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

ActiveRecord::Schema[8.1].define(version: 2026_05_22_246000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "athlete_contracts", force: :cascade do |t|
    t.bigint "athlete_id", null: false
    t.bigint "club_id", null: false
    t.datetime "created_at", null: false
    t.boolean "current", default: true, null: false
    t.date "end_date"
    t.boolean "loan", default: false, null: false
    t.date "loan_ends_on"
    t.bigint "parent_athlete_contract_id"
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
    t.index ["parent_athlete_contract_id"], name: "index_athlete_contracts_on_parent_athlete_contract_id"
  end

  create_table "athlete_season_stats", force: :cascade do |t|
    t.integer "appearances", default: 0, null: false
    t.integer "assists", default: 0, null: false
    t.bigint "athlete_id", null: false
    t.decimal "average_rating", precision: 4, scale: 2
    t.bigint "club_id", null: false
    t.datetime "created_at", null: false
    t.integer "goals", default: 0, null: false
    t.integer "injuries", default: 0, null: false
    t.integer "minutes_played", default: 0, null: false
    t.integer "red_cards", default: 0, null: false
    t.bigint "tournament_edition_id", null: false
    t.datetime "updated_at", null: false
    t.integer "yellow_cards", default: 0, null: false
    t.index ["athlete_id", "club_id", "tournament_edition_id"], name: "index_athlete_stats_on_athlete_club_edition", unique: true
    t.index ["athlete_id"], name: "index_athlete_season_stats_on_athlete_id"
    t.index ["club_id"], name: "index_athlete_season_stats_on_club_id"
    t.index ["tournament_edition_id"], name: "index_athlete_season_stats_on_tournament_edition_id"
  end

  create_table "athletes", force: :cascade do |t|
    t.boolean "academy_graduate", default: false, null: false
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
    t.date "injury_until"
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
    t.date "suspended_until"
    t.integer "tackling", default: 1, null: false
    t.integer "teamwork", default: 1, null: false
    t.integer "technique", default: 1, null: false
    t.datetime "updated_at", null: false
    t.integer "weight_kg"
    t.integer "work_rate", default: 1, null: false
    t.boolean "youth_academy_player", default: false, null: false
    t.bigint "youth_intake_id"
    t.index ["country_id"], name: "index_athletes_on_country_id"
    t.index ["youth_intake_id"], name: "index_athletes_on_youth_intake_id"
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

  create_table "club_season_stats", force: :cascade do |t|
    t.boolean "champion", default: false, null: false
    t.bigint "club_id", null: false
    t.datetime "created_at", null: false
    t.integer "draws", default: 0, null: false
    t.integer "goals_against", default: 0, null: false
    t.integer "goals_for", default: 0, null: false
    t.integer "losses", default: 0, null: false
    t.integer "played", default: 0, null: false
    t.integer "points", default: 0, null: false
    t.integer "position"
    t.bigint "tournament_edition_id", null: false
    t.datetime "updated_at", null: false
    t.integer "wins", default: 0, null: false
    t.index ["club_id", "tournament_edition_id"], name: "index_club_season_stats_on_club_id_and_tournament_edition_id", unique: true
    t.index ["club_id"], name: "index_club_season_stats_on_club_id"
    t.index ["tournament_edition_id"], name: "index_club_season_stats_on_tournament_edition_id"
  end

  create_table "clubs", force: :cascade do |t|
    t.integer "academy_quality", default: 5, null: false
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

  create_table "fixtures", force: :cascade do |t|
    t.bigint "away_club_id", null: false
    t.integer "away_goals"
    t.datetime "created_at", null: false
    t.bigint "home_club_id", null: false
    t.integer "home_goals"
    t.integer "kickoff_minute", default: 900, null: false
    t.integer "round", null: false
    t.date "scheduled_on", null: false
    t.bigint "stadium_id", null: false
    t.integer "status", default: 0, null: false
    t.bigint "tournament_edition_id", null: false
    t.datetime "updated_at", null: false
    t.index ["away_club_id"], name: "index_fixtures_on_away_club_id"
    t.index ["home_club_id"], name: "index_fixtures_on_home_club_id"
    t.index ["stadium_id"], name: "index_fixtures_on_stadium_id"
    t.index ["tournament_edition_id", "home_club_id", "away_club_id"], name: "index_fixtures_on_edition_home_away", unique: true
    t.index ["tournament_edition_id"], name: "index_fixtures_on_tournament_edition_id"
  end

  create_table "lineup_athletes", force: :cascade do |t|
    t.bigint "athlete_id", null: false
    t.datetime "created_at", null: false
    t.bigint "lineup_id", null: false
    t.integer "lineup_slot", null: false
    t.integer "position", null: false
    t.boolean "starter", default: true, null: false
    t.integer "substituted_off_minute"
    t.integer "substituted_on_minute"
    t.integer "tactical_role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["athlete_id"], name: "index_lineup_athletes_on_athlete_id"
    t.index ["lineup_id", "athlete_id"], name: "index_lineup_athletes_on_lineup_id_and_athlete_id", unique: true
    t.index ["lineup_id", "lineup_slot"], name: "index_lineup_athletes_on_lineup_id_and_lineup_slot", unique: true
    t.index ["lineup_id"], name: "index_lineup_athletes_on_lineup_id"
  end

  create_table "lineups", force: :cascade do |t|
    t.bigint "club_id", null: false
    t.datetime "created_at", null: false
    t.bigint "fixture_id", null: false
    t.string "formation", default: "4-4-2", null: false
    t.integer "mentality", default: 1, null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["club_id"], name: "index_lineups_on_club_id"
    t.index ["fixture_id", "club_id"], name: "index_lineups_on_fixture_id_and_club_id", unique: true
    t.index ["fixture_id"], name: "index_lineups_on_fixture_id"
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

  create_table "manager_season_stats", force: :cascade do |t|
    t.bigint "club_id", null: false
    t.datetime "created_at", null: false
    t.integer "draws", default: 0, null: false
    t.integer "losses", default: 0, null: false
    t.bigint "manager_id", null: false
    t.integer "matches", default: 0, null: false
    t.integer "position"
    t.integer "reputation_change", default: 0, null: false
    t.bigint "tournament_edition_id", null: false
    t.integer "trophies", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "wins", default: 0, null: false
    t.index ["club_id"], name: "index_manager_season_stats_on_club_id"
    t.index ["manager_id", "club_id", "tournament_edition_id"], name: "index_manager_stats_on_manager_club_edition", unique: true
    t.index ["manager_id"], name: "index_manager_season_stats_on_manager_id"
    t.index ["tournament_edition_id"], name: "index_manager_season_stats_on_tournament_edition_id"
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

  create_table "match_events", force: :cascade do |t|
    t.bigint "athlete_id", null: false
    t.bigint "club_id", null: false
    t.datetime "created_at", null: false
    t.string "description", null: false
    t.integer "event_type", default: 0, null: false
    t.bigint "fixture_id", null: false
    t.integer "minute", null: false
    t.datetime "updated_at", null: false
    t.index ["athlete_id"], name: "index_match_events_on_athlete_id"
    t.index ["club_id"], name: "index_match_events_on_club_id"
    t.index ["fixture_id", "minute", "id"], name: "index_match_events_on_fixture_id_and_minute_and_id"
    t.index ["fixture_id"], name: "index_match_events_on_fixture_id"
  end

  create_table "match_states", force: :cascade do |t|
    t.integer "away_substitutions", default: 0, null: false
    t.integer "clock_status", default: 0, null: false
    t.datetime "created_at", null: false
    t.bigint "fixture_id", null: false
    t.integer "home_substitutions", default: 0, null: false
    t.integer "minute", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["fixture_id"], name: "index_match_states_on_fixture_id", unique: true
  end

  create_table "match_stats", force: :cascade do |t|
    t.bigint "club_id", null: false
    t.datetime "created_at", null: false
    t.bigint "fixture_id", null: false
    t.integer "fouls", default: 0, null: false
    t.integer "possession", default: 50, null: false
    t.integer "red_cards", default: 0, null: false
    t.integer "shots", default: 0, null: false
    t.integer "shots_on_target", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "yellow_cards", default: 0, null: false
    t.index ["club_id"], name: "index_match_stats_on_club_id"
    t.index ["fixture_id", "club_id"], name: "index_match_stats_on_fixture_id_and_club_id", unique: true
    t.index ["fixture_id"], name: "index_match_stats_on_fixture_id"
  end

  create_table "news_items", force: :cascade do |t|
    t.bigint "athlete_id"
    t.text "body"
    t.bigint "career_id"
    t.integer "category", default: 0, null: false
    t.bigint "club_id"
    t.datetime "created_at", null: false
    t.bigint "manager_id"
    t.date "occurred_on", null: false
    t.string "title", null: false
    t.bigint "tournament_edition_id"
    t.datetime "updated_at", null: false
    t.index ["athlete_id"], name: "index_news_items_on_athlete_id"
    t.index ["career_id"], name: "index_news_items_on_career_id"
    t.index ["club_id"], name: "index_news_items_on_club_id"
    t.index ["manager_id"], name: "index_news_items_on_manager_id"
    t.index ["tournament_edition_id"], name: "index_news_items_on_tournament_edition_id"
  end

  create_table "scout_reports", force: :cascade do |t|
    t.bigint "athlete_id", null: false
    t.bigint "club_id", null: false
    t.integer "confidence", null: false
    t.datetime "created_at", null: false
    t.date "created_on", null: false
    t.integer "observed_current_ability", null: false
    t.integer "observed_potential_ability", null: false
    t.bigint "scouting_assignment_id"
    t.text "summary"
    t.datetime "updated_at", null: false
    t.index ["athlete_id"], name: "index_scout_reports_on_athlete_id"
    t.index ["club_id", "athlete_id"], name: "index_scout_reports_on_club_id_and_athlete_id", unique: true
    t.index ["club_id"], name: "index_scout_reports_on_club_id"
    t.index ["scouting_assignment_id"], name: "index_scout_reports_on_scouting_assignment_id"
  end

  create_table "scouting_assignments", force: :cascade do |t|
    t.bigint "club_id", null: false
    t.bigint "country_id"
    t.datetime "created_at", null: false
    t.date "ends_on", null: false
    t.integer "focus", default: 0, null: false
    t.integer "position"
    t.date "starts_on", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["club_id"], name: "index_scouting_assignments_on_club_id"
    t.index ["country_id"], name: "index_scouting_assignments_on_country_id"
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

  create_table "staff_contracts", force: :cascade do |t|
    t.bigint "club_id", null: false
    t.datetime "created_at", null: false
    t.boolean "current", default: true, null: false
    t.date "end_date"
    t.bigint "staff_member_id", null: false
    t.date "start_date", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.decimal "wage", precision: 15, scale: 2, default: "0.0", null: false
    t.index ["club_id"], name: "index_staff_contracts_on_club_id"
    t.index ["staff_member_id", "current"], name: "index_staff_contracts_on_staff_member_id_and_current", unique: true, where: "current"
    t.index ["staff_member_id"], name: "index_staff_contracts_on_staff_member_id"
  end

  create_table "staff_members", force: :cascade do |t|
    t.integer "coaching", default: 1, null: false
    t.bigint "country_id", null: false
    t.datetime "created_at", null: false
    t.integer "discipline", default: 1, null: false
    t.string "first_name", null: false
    t.integer "fitness", default: 1, null: false
    t.integer "judging_ability", default: 1, null: false
    t.integer "judging_potential", default: 1, null: false
    t.string "last_name", null: false
    t.integer "motivation", default: 1, null: false
    t.integer "physiotherapy", default: 1, null: false
    t.integer "reputation", default: 1, null: false
    t.integer "role", default: 0, null: false
    t.integer "scouting", default: 1, null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_staff_members_on_country_id"
  end

  create_table "tournament_editions", force: :cascade do |t|
    t.bigint "champion_id"
    t.datetime "created_at", null: false
    t.date "ends_on", null: false
    t.string "name", null: false
    t.integer "season_year", null: false
    t.date "starts_on", null: false
    t.integer "status", default: 0, null: false
    t.bigint "tournament_id", null: false
    t.datetime "updated_at", null: false
    t.index ["champion_id"], name: "index_tournament_editions_on_champion_id"
    t.index ["tournament_id", "season_year"], name: "index_tournament_editions_on_tournament_id_and_season_year", unique: true
    t.index ["tournament_id"], name: "index_tournament_editions_on_tournament_id"
  end

  create_table "tournament_participations", force: :cascade do |t|
    t.bigint "club_id", null: false
    t.datetime "created_at", null: false
    t.integer "draws", default: 0, null: false
    t.integer "goals_against", default: 0, null: false
    t.integer "goals_for", default: 0, null: false
    t.integer "losses", default: 0, null: false
    t.integer "played", default: 0, null: false
    t.integer "points", default: 0, null: false
    t.integer "position"
    t.decimal "prize_money", precision: 15, scale: 2, default: "0.0", null: false
    t.integer "status", default: 0, null: false
    t.bigint "tournament_edition_id", null: false
    t.datetime "updated_at", null: false
    t.integer "wins", default: 0, null: false
    t.index ["club_id"], name: "index_tournament_participations_on_club_id"
    t.index ["tournament_edition_id", "club_id"], name: "idx_on_tournament_edition_id_club_id_27e3f58eda", unique: true
    t.index ["tournament_edition_id"], name: "index_tournament_participations_on_tournament_edition_id"
  end

  create_table "tournaments", force: :cascade do |t|
    t.bigint "country_id", null: false
    t.datetime "created_at", null: false
    t.integer "format", default: 0, null: false
    t.string "name", null: false
    t.integer "scope", default: 0, null: false
    t.string "short_name", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["country_id", "name"], name: "index_tournaments_on_country_id_and_name", unique: true
    t.index ["country_id"], name: "index_tournaments_on_country_id"
  end

  create_table "training_plans", force: :cascade do |t|
    t.date "active_from", null: false
    t.bigint "club_id", null: false
    t.datetime "created_at", null: false
    t.integer "focus", default: 0, null: false
    t.integer "intensity", default: 1, null: false
    t.bigint "manager_id", null: false
    t.datetime "updated_at", null: false
    t.index ["club_id"], name: "index_training_plans_on_club_id", unique: true
    t.index ["manager_id"], name: "index_training_plans_on_manager_id"
  end

  create_table "training_results", force: :cascade do |t|
    t.bigint "athlete_id", null: false
    t.string "attribute_name", null: false
    t.bigint "club_id", null: false
    t.integer "condition_change", default: 0, null: false
    t.datetime "created_at", null: false
    t.integer "new_value", null: false
    t.date "occurred_on", null: false
    t.integer "old_value", null: false
    t.bigint "training_plan_id", null: false
    t.datetime "updated_at", null: false
    t.index ["athlete_id"], name: "index_training_results_on_athlete_id"
    t.index ["club_id"], name: "index_training_results_on_club_id"
    t.index ["training_plan_id"], name: "index_training_results_on_training_plan_id"
  end

  create_table "transfer_offers", force: :cascade do |t|
    t.bigint "athlete_id", null: false
    t.datetime "created_at", null: false
    t.date "decided_on"
    t.date "expires_on", null: false
    t.bigint "from_club_id"
    t.date "loan_ends_on"
    t.text "notes"
    t.decimal "offered_fee", precision: 15, scale: 2, default: "0.0", null: false
    t.date "offered_on", null: false
    t.decimal "offered_wage", precision: 15, scale: 2, default: "0.0", null: false
    t.integer "status", default: 0, null: false
    t.bigint "to_club_id", null: false
    t.integer "transfer_type", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["athlete_id", "to_club_id", "status"], name: "index_transfer_offers_on_athlete_id_and_to_club_id_and_status"
    t.index ["athlete_id"], name: "index_transfer_offers_on_athlete_id"
    t.index ["from_club_id"], name: "index_transfer_offers_on_from_club_id"
    t.index ["to_club_id"], name: "index_transfer_offers_on_to_club_id"
  end

  create_table "transfers", force: :cascade do |t|
    t.bigint "athlete_id", null: false
    t.datetime "created_at", null: false
    t.decimal "fee", precision: 15, scale: 2, default: "0.0", null: false
    t.bigint "from_club_id"
    t.date "loan_ends_on"
    t.integer "status", default: 0, null: false
    t.bigint "to_club_id", null: false
    t.date "transfer_date", null: false
    t.integer "transfer_type", default: 0, null: false
    t.datetime "updated_at", null: false
    t.decimal "wage", precision: 15, scale: 2, default: "0.0", null: false
    t.index ["athlete_id", "transfer_date", "to_club_id"], name: "index_transfers_on_athlete_id_and_transfer_date_and_to_club_id"
    t.index ["athlete_id"], name: "index_transfers_on_athlete_id"
    t.index ["from_club_id"], name: "index_transfers_on_from_club_id"
    t.index ["to_club_id"], name: "index_transfers_on_to_club_id"
  end

  create_table "trophies", force: :cascade do |t|
    t.bigint "club_id", null: false
    t.datetime "created_at", null: false
    t.bigint "manager_id"
    t.string "name", null: false
    t.bigint "tournament_edition_id", null: false
    t.datetime "updated_at", null: false
    t.date "won_on", null: false
    t.index ["club_id"], name: "index_trophies_on_club_id"
    t.index ["manager_id"], name: "index_trophies_on_manager_id"
    t.index ["tournament_edition_id", "club_id"], name: "index_trophies_on_tournament_edition_id_and_club_id", unique: true
    t.index ["tournament_edition_id"], name: "index_trophies_on_tournament_edition_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  create_table "youth_intakes", force: :cascade do |t|
    t.bigint "club_id", null: false
    t.datetime "created_at", null: false
    t.date "generated_on", null: false
    t.integer "season_year", null: false
    t.datetime "updated_at", null: false
    t.index ["club_id", "season_year"], name: "index_youth_intakes_on_club_id_and_season_year", unique: true
    t.index ["club_id"], name: "index_youth_intakes_on_club_id"
  end

  add_foreign_key "athlete_contracts", "athlete_contracts", column: "parent_athlete_contract_id"
  add_foreign_key "athlete_contracts", "athletes"
  add_foreign_key "athlete_contracts", "clubs"
  add_foreign_key "athlete_season_stats", "athletes"
  add_foreign_key "athlete_season_stats", "clubs"
  add_foreign_key "athlete_season_stats", "tournament_editions"
  add_foreign_key "athletes", "countries"
  add_foreign_key "athletes", "youth_intakes"
  add_foreign_key "careers", "users"
  add_foreign_key "club_finances", "clubs"
  add_foreign_key "club_season_stats", "clubs"
  add_foreign_key "club_season_stats", "tournament_editions"
  add_foreign_key "clubs", "countries"
  add_foreign_key "fixtures", "clubs", column: "away_club_id"
  add_foreign_key "fixtures", "clubs", column: "home_club_id"
  add_foreign_key "fixtures", "stadiums"
  add_foreign_key "fixtures", "tournament_editions"
  add_foreign_key "lineup_athletes", "athletes"
  add_foreign_key "lineup_athletes", "lineups"
  add_foreign_key "lineups", "clubs"
  add_foreign_key "lineups", "fixtures"
  add_foreign_key "manager_contracts", "clubs"
  add_foreign_key "manager_contracts", "managers"
  add_foreign_key "manager_season_stats", "clubs"
  add_foreign_key "manager_season_stats", "managers"
  add_foreign_key "manager_season_stats", "tournament_editions"
  add_foreign_key "managers", "careers"
  add_foreign_key "managers", "countries"
  add_foreign_key "managers", "users"
  add_foreign_key "match_events", "athletes"
  add_foreign_key "match_events", "clubs"
  add_foreign_key "match_events", "fixtures"
  add_foreign_key "match_states", "fixtures"
  add_foreign_key "match_stats", "clubs"
  add_foreign_key "match_stats", "fixtures"
  add_foreign_key "news_items", "athletes"
  add_foreign_key "news_items", "careers"
  add_foreign_key "news_items", "clubs"
  add_foreign_key "news_items", "managers"
  add_foreign_key "news_items", "tournament_editions"
  add_foreign_key "scout_reports", "athletes"
  add_foreign_key "scout_reports", "clubs"
  add_foreign_key "scout_reports", "scouting_assignments"
  add_foreign_key "scouting_assignments", "clubs"
  add_foreign_key "scouting_assignments", "countries"
  add_foreign_key "sessions", "users"
  add_foreign_key "stadiums", "clubs"
  add_foreign_key "stadiums", "countries"
  add_foreign_key "staff_contracts", "clubs"
  add_foreign_key "staff_contracts", "staff_members"
  add_foreign_key "staff_members", "countries"
  add_foreign_key "tournament_editions", "clubs", column: "champion_id"
  add_foreign_key "tournament_editions", "tournaments"
  add_foreign_key "tournament_participations", "clubs"
  add_foreign_key "tournament_participations", "tournament_editions"
  add_foreign_key "tournaments", "countries"
  add_foreign_key "training_plans", "clubs"
  add_foreign_key "training_plans", "managers"
  add_foreign_key "training_results", "athletes"
  add_foreign_key "training_results", "clubs"
  add_foreign_key "training_results", "training_plans"
  add_foreign_key "transfer_offers", "athletes"
  add_foreign_key "transfer_offers", "clubs", column: "from_club_id"
  add_foreign_key "transfer_offers", "clubs", column: "to_club_id"
  add_foreign_key "transfers", "athletes"
  add_foreign_key "transfers", "clubs", column: "from_club_id"
  add_foreign_key "transfers", "clubs", column: "to_club_id"
  add_foreign_key "trophies", "clubs"
  add_foreign_key "trophies", "managers"
  add_foreign_key "trophies", "tournament_editions"
  add_foreign_key "youth_intakes", "clubs"
end
