class CreateAthleteContracts < ActiveRecord::Migration[8.1]
  def change
    create_table :athlete_contracts do |t|
      t.references :athlete, null: false, foreign_key: true
      t.references :club, null: false, foreign_key: true
      t.date :start_date, null: false
      t.date :end_date
      t.decimal :wage, precision: 15, scale: 2, null: false, default: 0
      t.decimal :release_clause, precision: 15, scale: 2
      t.integer :squad_number
      t.integer :status, null: false, default: 0
      t.boolean :current, null: false, default: true
      t.boolean :loan, null: false, default: false

      t.timestamps
    end

    add_index :athlete_contracts, [ :athlete_id, :current ], where: "current"
    add_index :athlete_contracts, [ :club_id, :squad_number, :current ], unique: true, where: "current AND squad_number IS NOT NULL"
  end
end
