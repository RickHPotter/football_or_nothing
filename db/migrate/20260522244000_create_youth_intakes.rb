class CreateYouthIntakes < ActiveRecord::Migration[8.1]
  def change
    add_column :clubs, :academy_quality, :integer, null: false, default: 5

    create_table :youth_intakes do |t|
      t.references :club, null: false, foreign_key: true
      t.integer :season_year, null: false
      t.date :generated_on, null: false

      t.timestamps
    end

    add_index :youth_intakes, [ :club_id, :season_year ], unique: true

    add_reference :athletes, :youth_intake, foreign_key: true
    add_column :athletes, :youth_academy_player, :boolean, null: false, default: false
    add_column :athletes, :academy_graduate, :boolean, null: false, default: false
  end
end
