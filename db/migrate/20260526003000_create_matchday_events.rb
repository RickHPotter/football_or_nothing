# frozen_string_literal: true

class CreateMatchdayEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :matchday_events do |t|
      t.references :matchday_session, null: false, foreign_key: true
      t.references :fixture, null: false, foreign_key: true
      t.references :club, null: false, foreign_key: true
      t.references :athlete, null: false, foreign_key: true
      t.integer :minute, null: false
      t.integer :event_type, null: false
      t.string :description, null: false
      t.datetime :applied_at

      t.timestamps
    end

    add_index :matchday_events, %i[matchday_session_id fixture_id minute id], name: "index_matchday_events_on_session_fixture_minute"
  end
end
