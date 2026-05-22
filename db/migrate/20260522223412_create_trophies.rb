class CreateTrophies < ActiveRecord::Migration[8.1]
  def change
    create_table :trophies do |t|
      t.references :tournament_edition, null: false, foreign_key: true
      t.references :club, null: false, foreign_key: true
      t.references :manager, foreign_key: true
      t.string :name, null: false
      t.date :won_on, null: false

      t.timestamps
    end

    add_index :trophies, [ :tournament_edition_id, :club_id ], unique: true
  end
end
