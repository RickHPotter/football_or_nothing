# frozen_string_literal: true

class CreateMatchdaySessions < ActiveRecord::Migration[8.1]
  def change
    create_table :matchday_sessions do |t|
      t.references :career, null: false, foreign_key: true
      t.references :tournament_edition, null: false, foreign_key: true
      t.references :focused_fixture, foreign_key: { to_table: :fixtures }
      t.date :scheduled_on, null: false
      t.integer :round, null: false
      t.integer :status, null: false, default: 0
      t.integer :period, null: false, default: 0
      t.integer :minute, null: false, default: 0
      t.integer :elapsed_seconds, null: false, default: 0
      t.integer :total_duration_seconds, null: false, default: 20
      t.datetime :started_at
      t.datetime :paused_at

      t.timestamps
    end

    add_index :matchday_sessions,
              %i[career_id tournament_edition_id scheduled_on round],
              unique: true,
              name: "index_matchday_sessions_on_matchday"
  end
end
