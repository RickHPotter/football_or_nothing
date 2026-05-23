class CreateLineups < ActiveRecord::Migration[8.1]
  def change
    create_table :lineups do |t|
      t.references :fixture, null: false, foreign_key: true
      t.references :club, null: false, foreign_key: true
      t.string :formation, null: false, default: "4-4-2"
      t.integer :mentality, null: false, default: 1
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :lineups, [ :fixture_id, :club_id ], unique: true
  end
end
