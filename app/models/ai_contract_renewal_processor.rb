# frozen_string_literal: true

class AiContractRenewalProcessor
  RENEWAL_LENGTH = 1.year

  def self.call(...)
    new(...).call
  end

  def initialize(cutoff_date:)
    @cutoff_date = cutoff_date
  end

  def call
    renewable_contracts.find_each.with_object([]) do |contract, renewed|
      next unless renew?(contract)

      contract.update!(
        end_date: cutoff_date + RENEWAL_LENGTH,
        wage: proposed_wage(contract)
      )
      renewed << contract
    end
  end

  private

  attr_reader :cutoff_date

  def renewable_contracts
    AthleteContract
      .includes(:athlete, club: :club_finance)
      .where(current: true, loan: false, status: :active)
      .where.not(end_date: nil)
      .where(end_date: ...cutoff_date)
  end

  def renew?(contract)
    return false unless contract.athlete.current_ability >= 8
    return false unless contract.club.club_finance

    contract.club.club_finance.available_wage_budget + contract.wage >= proposed_wage(contract)
  end

  def proposed_wage(contract)
    [ contract.wage * BigDecimal("1.05"), contract.athlete.current_ability * 25 ].max
  end
end
