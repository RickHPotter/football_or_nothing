class CreateStadia < ActiveRecord::Migration[8.1]
  def change
    create_table :stadiums do |t|
      t.references :country, null: false, foreign_key: true
      t.references :club, null: false, foreign_key: true
      t.string :name, null: false
      t.string :city, null: false
      t.integer :capacity, null: false, default: 0
      t.integer :pitch_quality, null: false, default: 1
      t.integer :ownership, null: false, default: 0

      t.timestamps
    end

    add_index :stadiums, [ :country_id, :name ], unique: true
  end
end
