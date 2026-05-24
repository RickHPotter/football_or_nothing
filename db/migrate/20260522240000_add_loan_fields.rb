class AddLoanFields < ActiveRecord::Migration[8.1]
  def change
    add_reference :athlete_contracts, :parent_athlete_contract, foreign_key: { to_table: :athlete_contracts }
    add_column :athlete_contracts, :loan_ends_on, :date

    add_column :transfers, :loan_ends_on, :date

    add_column :transfer_offers, :transfer_type, :integer, null: false, default: 0
    add_column :transfer_offers, :loan_ends_on, :date
  end
end
