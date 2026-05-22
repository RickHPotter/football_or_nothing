class CreateClubs < ActiveRecord::Migration[8.1]
  def change
    create_table :clubs do |t|
      t.references :country, null: false, foreign_key: true
      t.string :name, null: false
      t.string :short_name, null: false
      t.integer :reputation, null: false, default: 1
      t.integer :founded_year
      t.boolean :international, null: false, default: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :clubs, [ :country_id, :name ], unique: true
  end
end
