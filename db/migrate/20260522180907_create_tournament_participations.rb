class CreateTournamentParticipations < ActiveRecord::Migration[8.1]
  def change
    create_table :tournament_participations do |t|
      t.references :tournament_edition, null: false, foreign_key: true
      t.references :club, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.integer :position
      t.integer :played, null: false, default: 0
      t.integer :wins, null: false, default: 0
      t.integer :draws, null: false, default: 0
      t.integer :losses, null: false, default: 0
      t.integer :goals_for, null: false, default: 0
      t.integer :goals_against, null: false, default: 0
      t.integer :points, null: false, default: 0
      t.decimal :prize_money, precision: 15, scale: 2, null: false, default: 0

      t.timestamps
    end

    add_index :tournament_participations, [ :tournament_edition_id, :club_id ], unique: true
  end
end
