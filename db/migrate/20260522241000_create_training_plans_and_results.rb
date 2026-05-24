class CreateTrainingPlansAndResults < ActiveRecord::Migration[8.1]
  def change
    create_table :training_plans do |t|
      t.references :club, null: false, foreign_key: true, index: { unique: true }
      t.references :manager, null: false, foreign_key: true
      t.integer :focus, null: false, default: 0
      t.integer :intensity, null: false, default: 1
      t.date :active_from, null: false

      t.timestamps
    end

    create_table :training_results do |t|
      t.references :training_plan, null: false, foreign_key: true
      t.references :club, null: false, foreign_key: true
      t.references :athlete, null: false, foreign_key: true
      t.date :occurred_on, null: false
      t.string :attribute_name, null: false
      t.integer :old_value, null: false
      t.integer :new_value, null: false
      t.integer :condition_change, null: false, default: 0

      t.timestamps
    end
  end
end
