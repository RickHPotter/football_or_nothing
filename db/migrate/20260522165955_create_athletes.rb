class CreateAthletes < ActiveRecord::Migration[8.1]
  def change
    create_table :athletes do |t|
      t.references :country, null: false, foreign_key: true
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.date :birthdate
      t.integer :position, null: false, default: 0
      t.integer :preferred_foot, null: false, default: 0
      t.integer :height_cm
      t.integer :weight_kg
      t.integer :current_ability, null: false, default: 1
      t.integer :potential_ability, null: false, default: 1
      t.integer :reputation, null: false, default: 1
      t.integer :morale, null: false, default: 50
      t.integer :condition, null: false, default: 100
      t.integer :status, null: false, default: 0
      t.integer :finishing, null: false, default: 1
      t.integer :long_shots, null: false, default: 1
      t.integer :passing, null: false, default: 1
      t.integer :crossing, null: false, default: 1
      t.integer :dribbling, null: false, default: 1
      t.integer :technique, null: false, default: 1
      t.integer :first_touch, null: false, default: 1
      t.integer :tackling, null: false, default: 1
      t.integer :marking, null: false, default: 1
      t.integer :positioning, null: false, default: 1
      t.integer :heading, null: false, default: 1
      t.integer :pace, null: false, default: 1
      t.integer :acceleration, null: false, default: 1
      t.integer :stamina, null: false, default: 1
      t.integer :strength, null: false, default: 1
      t.integer :jumping, null: false, default: 1
      t.integer :decisions, null: false, default: 1
      t.integer :composure, null: false, default: 1
      t.integer :teamwork, null: false, default: 1
      t.integer :work_rate, null: false, default: 1

      t.timestamps
    end
  end
end
