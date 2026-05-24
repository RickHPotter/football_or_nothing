# frozen_string_literal: true

class ClubFinance < ApplicationRecord
  belongs_to :club

  validates :club_id, uniqueness: true
  validates :cash_balance, :wage_budget, :transfer_budget, :debt,
            :sponsorship_income, :stadium_income, :prize_money, :expenses,
            numericality: true

  def available_wage_budget
    wage_budget - club.current_wage_total
  end
end
