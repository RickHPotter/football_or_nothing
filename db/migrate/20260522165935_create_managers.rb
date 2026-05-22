class CreateManagers < ActiveRecord::Migration[8.1]
  def change
    create_table :managers do |t|
      t.references :user, null: false, foreign_key: true
      t.references :career, null: false, foreign_key: true, index: { unique: true }
      t.references :country, null: false, foreign_key: true
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.date :birthdate
      t.integer :reputation, null: false, default: 1
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
