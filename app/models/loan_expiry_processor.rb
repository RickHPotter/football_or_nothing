# frozen_string_literal: true

class LoanExpiryProcessor
  def self.call(...)
    new(...).call
  end

  def initialize(cutoff_date:)
    @cutoff_date = cutoff_date
  end

  def call
    AthleteContract
      .includes(:parent_athlete_contract)
      .where(current: true, loan: true)
      .where.not(loan_ends_on: nil)
      .where(loan_ends_on: ...cutoff_date)
      .find_each do |loan_contract|
        expire_loan!(loan_contract)
      end
  end

  private

  attr_reader :cutoff_date

  def expire_loan!(loan_contract)
    AthleteContract.transaction do
      parent_contract = loan_contract.parent_athlete_contract

      loan_contract.update!(
        current: false,
        status: :expired,
        end_date: loan_contract.loan_ends_on
      )

      parent_contract&.update!(current: true, status: :active)
    end
  end
end
