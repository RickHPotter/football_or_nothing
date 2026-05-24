class CreateScoutingAssignmentsAndReports < ActiveRecord::Migration[8.1]
  def change
    create_table :scouting_assignments do |t|
      t.references :club, null: false, foreign_key: true
      t.references :country, foreign_key: true
      t.integer :position
      t.integer :focus, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.date :starts_on, null: false
      t.date :ends_on, null: false

      t.timestamps
    end

    create_table :scout_reports do |t|
      t.references :club, null: false, foreign_key: true
      t.references :athlete, null: false, foreign_key: true
      t.references :scouting_assignment, foreign_key: true
      t.integer :observed_current_ability, null: false
      t.integer :observed_potential_ability, null: false
      t.integer :confidence, null: false
      t.text :summary
      t.date :created_on, null: false

      t.timestamps
    end

    add_index :scout_reports, [ :club_id, :athlete_id ], unique: true
  end
end
