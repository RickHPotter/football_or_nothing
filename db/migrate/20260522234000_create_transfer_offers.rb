class CreateTransferOffers < ActiveRecord::Migration[8.1]
  def change
    create_table :transfer_offers do |t|
      t.references :athlete, null: false, foreign_key: true
      t.references :from_club, foreign_key: { to_table: :clubs }
      t.references :to_club, null: false, foreign_key: { to_table: :clubs }
      t.decimal :offered_fee, precision: 15, scale: 2, null: false, default: 0
      t.decimal :offered_wage, precision: 15, scale: 2, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.date :offered_on, null: false
      t.date :expires_on, null: false
      t.date :decided_on
      t.text :notes

      t.timestamps
    end

    add_index :transfer_offers, [ :athlete_id, :to_club_id, :status ]
  end
end
