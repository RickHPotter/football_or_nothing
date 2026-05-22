class CreateManagerContracts < ActiveRecord::Migration[8.1]
  def change
    create_table :manager_contracts do |t|
      t.references :manager, null: false, foreign_key: true
      t.references :club, null: false, foreign_key: true
      t.date :start_date, null: false
      t.date :end_date
      t.decimal :wage, precision: 15, scale: 2, null: false, default: 0
      t.integer :role, null: false, default: 0
      t.text :expectations
      t.integer :status, null: false, default: 0
      t.boolean :current, null: false, default: true

      t.timestamps
    end

    add_index :manager_contracts, [ :manager_id, :current ], where: "current"
    add_index :manager_contracts, [ :club_id, :current ], where: "current"
  end
end
