class CreateAthleteSeasonStats < ActiveRecord::Migration[8.1]
  def change
    create_table :athlete_season_stats do |t|
      t.references :athlete, null: false, foreign_key: true
      t.references :club, null: false, foreign_key: true
      t.references :tournament_edition, null: false, foreign_key: true
      t.integer :appearances, null: false, default: 0
      t.integer :goals, null: false, default: 0
      t.integer :assists, null: false, default: 0
      t.integer :minutes_played, null: false, default: 0
      t.decimal :average_rating, precision: 4, scale: 2

      t.timestamps
    end

    add_index :athlete_season_stats, [ :athlete_id, :club_id, :tournament_edition_id ], unique: true, name: "index_athlete_stats_on_athlete_club_edition"
  end
end
