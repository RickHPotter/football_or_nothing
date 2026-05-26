# frozen_string_literal: true

class AddSlotKeyToLineupAthletes < ActiveRecord::Migration[8.1]
  def change
    add_column :lineup_athletes, :lineup_slot_key, :string, null: false, default: "slot"
  end
end
