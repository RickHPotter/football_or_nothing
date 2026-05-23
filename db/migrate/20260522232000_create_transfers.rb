class CreateTransfers < ActiveRecord::Migration[8.1]
  def change
    create_table :transfers do |t|
      t.references :athlete, null: false, foreign_key: true
      t.references :from_club, foreign_key: { to_table: :clubs }
      t.references :to_club, null: false, foreign_key: { to_table: :clubs }
      t.date :transfer_date, null: false
      t.decimal :fee, precision: 15, scale: 2, null: false, default: 0
      t.decimal :wage, precision: 15, scale: 2, null: false, default: 0
      t.integer :transfer_type, null: false, default: 0
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :transfers, [ :athlete_id, :transfer_date, :to_club_id ]
  end
end
