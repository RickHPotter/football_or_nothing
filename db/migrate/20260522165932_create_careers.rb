class CreateCareers < ActiveRecord::Migration[8.1]
  def change
    create_table :careers do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.date :current_date, null: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
