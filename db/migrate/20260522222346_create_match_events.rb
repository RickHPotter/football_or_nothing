class CreateMatchEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :match_events do |t|
      t.references :fixture, null: false, foreign_key: true
      t.references :club, null: false, foreign_key: true
      t.references :athlete, null: false, foreign_key: true
      t.integer :minute, null: false
      t.integer :event_type, null: false, default: 0
      t.string :description, null: false

      t.timestamps
    end

    add_index :match_events, [ :fixture_id, :minute, :id ]
  end
end
