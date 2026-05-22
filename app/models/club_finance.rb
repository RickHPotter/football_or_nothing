class ClubFinance < ApplicationRecord
  belongs_to :club

  validates :club_id, uniqueness: true
  validates :cash_balance, :wage_budget, :transfer_budget, :debt,
    :sponsorship_income, :stadium_income, :prize_money, :expenses,
    numericality: true
end
