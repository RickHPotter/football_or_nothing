class CreateTournamentEditions < ActiveRecord::Migration[8.1]
  def change
    create_table :tournament_editions do |t|
      t.references :tournament, null: false, foreign_key: true
      t.integer :season_year, null: false
      t.string :name, null: false
      t.date :starts_on, null: false
      t.date :ends_on, null: false
      t.integer :status, null: false, default: 0
      t.references :champion, foreign_key: { to_table: :clubs }

      t.timestamps
    end

    add_index :tournament_editions, [ :tournament_id, :season_year ], unique: true
  end
end
