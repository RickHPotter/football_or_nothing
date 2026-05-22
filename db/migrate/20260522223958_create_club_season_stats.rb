class CreateClubSeasonStats < ActiveRecord::Migration[8.1]
  def change
    create_table :club_season_stats do |t|
      t.references :club, null: false, foreign_key: true
      t.references :tournament_edition, null: false, foreign_key: true
      t.integer :position
      t.integer :played, null: false, default: 0
      t.integer :wins, null: false, default: 0
      t.integer :draws, null: false, default: 0
      t.integer :losses, null: false, default: 0
      t.integer :goals_for, null: false, default: 0
      t.integer :goals_against, null: false, default: 0
      t.integer :points, null: false, default: 0
      t.boolean :champion, null: false, default: false

      t.timestamps
    end

    add_index :club_season_stats, [ :club_id, :tournament_edition_id ], unique: true
  end
end
