class CreateMatchdayStandingSnapshots < ActiveRecord::Migration[8.1]
  def change
    create_table :matchday_standing_snapshots do |t|
      t.references :matchday_session, null: false, foreign_key: true
      t.references :tournament_participation, null: false, foreign_key: true
      t.references :club, null: false, foreign_key: true
      t.integer :position_before
      t.integer :position_after

      t.timestamps
    end

    add_index :matchday_standing_snapshots,
              %i[matchday_session_id tournament_participation_id],
              unique: true,
              name: "index_matchday_standing_snapshots_on_session_participation"
  end
end
