class CreateTournaments < ActiveRecord::Migration[8.1]
  def change
    create_table :tournaments do |t|
      t.references :country, null: false, foreign_key: true
      t.string :name, null: false
      t.string :short_name, null: false
      t.integer :scope, null: false, default: 0
      t.integer :format, null: false, default: 0
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :tournaments, [ :country_id, :name ], unique: true
  end
end
