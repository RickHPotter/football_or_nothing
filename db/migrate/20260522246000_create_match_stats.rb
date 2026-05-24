class CreateMatchStats < ActiveRecord::Migration[8.1]
  def change
    create_table :match_stats do |t|
      t.references :fixture, null: false, foreign_key: true
      t.references :club, null: false, foreign_key: true
      t.integer :possession, null: false, default: 50
      t.integer :shots, null: false, default: 0
      t.integer :shots_on_target, null: false, default: 0
      t.integer :fouls, null: false, default: 0
      t.integer :yellow_cards, null: false, default: 0
      t.integer :red_cards, null: false, default: 0

      t.timestamps
    end

    add_index :match_stats, [ :fixture_id, :club_id ], unique: true
  end
end
