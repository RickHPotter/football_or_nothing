class CreateStaffMembersAndContracts < ActiveRecord::Migration[8.1]
  def change
    create_table :staff_members do |t|
      t.references :country, null: false, foreign_key: true
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.integer :role, null: false, default: 0
      t.integer :reputation, null: false, default: 1
      t.integer :coaching, null: false, default: 1
      t.integer :fitness, null: false, default: 1
      t.integer :scouting, null: false, default: 1
      t.integer :judging_ability, null: false, default: 1
      t.integer :judging_potential, null: false, default: 1
      t.integer :physiotherapy, null: false, default: 1
      t.integer :discipline, null: false, default: 1
      t.integer :motivation, null: false, default: 1
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    create_table :staff_contracts do |t|
      t.references :staff_member, null: false, foreign_key: true
      t.references :club, null: false, foreign_key: true
      t.date :start_date, null: false
      t.date :end_date
      t.decimal :wage, precision: 15, scale: 2, null: false, default: 0
      t.boolean :current, null: false, default: true
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :staff_contracts, [ :staff_member_id, :current ], unique: true, where: "current"
  end
end
