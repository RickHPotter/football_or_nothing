class CreateNewsItems < ActiveRecord::Migration[8.1]
  def change
    create_table :news_items do |t|
      t.references :career, foreign_key: true
      t.references :club, foreign_key: true
      t.references :athlete, foreign_key: true
      t.references :manager, foreign_key: true
      t.references :tournament_edition, foreign_key: true
      t.integer :category, null: false, default: 0
      t.string :title, null: false
      t.text :body
      t.date :occurred_on, null: false

      t.timestamps
    end
  end
end
