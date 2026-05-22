class CreateFixtures < ActiveRecord::Migration[8.1]
  def change
    create_table :fixtures do |t|
      t.references :tournament_edition, null: false, foreign_key: true
      t.references :home_club, null: false, foreign_key: { to_table: :clubs }
      t.references :away_club, null: false, foreign_key: { to_table: :clubs }
      t.references :stadium, null: false, foreign_key: true
      t.date :scheduled_on, null: false
      t.integer :kickoff_minute, null: false, default: 900
      t.integer :status, null: false, default: 0
      t.integer :home_goals
      t.integer :away_goals
      t.integer :round, null: false

      t.timestamps
    end

    add_index :fixtures, [ :tournament_edition_id, :home_club_id, :away_club_id ], unique: true, name: "index_fixtures_on_edition_home_away"
  end
end
