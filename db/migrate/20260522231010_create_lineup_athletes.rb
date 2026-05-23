class CreateLineupAthletes < ActiveRecord::Migration[8.1]
  def change
    create_table :lineup_athletes do |t|
      t.references :lineup, null: false, foreign_key: true
      t.references :athlete, null: false, foreign_key: true
      t.integer :position, null: false
      t.integer :tactical_role, null: false, default: 0
      t.integer :lineup_slot, null: false
      t.boolean :starter, null: false, default: true
      t.integer :substituted_on_minute
      t.integer :substituted_off_minute

      t.timestamps
    end

    add_index :lineup_athletes, [ :lineup_id, :athlete_id ], unique: true
    add_index :lineup_athletes, [ :lineup_id, :lineup_slot ], unique: true
  end
end
