class CreateMatchStates < ActiveRecord::Migration[8.1]
  def change
    create_table :match_states do |t|
      t.references :fixture, null: false, foreign_key: true, index: { unique: true }
      t.integer :minute, null: false, default: 0
      t.integer :clock_status, null: false, default: 0
      t.integer :home_substitutions, null: false, default: 0
      t.integer :away_substitutions, null: false, default: 0

      t.timestamps
    end
  end
end
