class CreateClubFinances < ActiveRecord::Migration[8.1]
  def change
    create_table :club_finances do |t|
      t.references :club, null: false, foreign_key: true, index: { unique: true }
      t.decimal :cash_balance, precision: 15, scale: 2, null: false, default: 0
      t.decimal :wage_budget, precision: 15, scale: 2, null: false, default: 0
      t.decimal :transfer_budget, precision: 15, scale: 2, null: false, default: 0
      t.decimal :debt, precision: 15, scale: 2, null: false, default: 0
      t.decimal :sponsorship_income, precision: 15, scale: 2, null: false, default: 0
      t.decimal :stadium_income, precision: 15, scale: 2, null: false, default: 0
      t.decimal :prize_money, precision: 15, scale: 2, null: false, default: 0
      t.decimal :expenses, precision: 15, scale: 2, null: false, default: 0

      t.timestamps
    end
  end
end
