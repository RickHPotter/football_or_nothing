class CreateManagerSeasonStats < ActiveRecord::Migration[8.1]
  def change
    create_table :manager_season_stats do |t|
      t.references :manager, null: false, foreign_key: true
      t.references :club, null: false, foreign_key: true
      t.references :tournament_edition, null: false, foreign_key: true
      t.integer :position
      t.integer :matches, null: false, default: 0
      t.integer :wins, null: false, default: 0
      t.integer :draws, null: false, default: 0
      t.integer :losses, null: false, default: 0
      t.integer :trophies, null: false, default: 0
      t.integer :reputation_change, null: false, default: 0

      t.timestamps
    end

    add_index :manager_season_stats, [ :manager_id, :club_id, :tournament_edition_id ], unique: true, name: "index_manager_stats_on_manager_club_edition"
  end
end
