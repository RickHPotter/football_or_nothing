class AddAvailabilityToAthletes < ActiveRecord::Migration[8.1]
  def change
    add_column :athletes, :injury_until, :date
    add_column :athletes, :suspended_until, :date
  end
end
