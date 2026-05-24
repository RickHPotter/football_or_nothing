# frozen_string_literal: true

require "test_helper"

class ContractExpiryProcessorTest < ActiveSupport::TestCase
  test "expires current athlete contracts before cutoff date" do
    contract = athlete_contracts(:one)
    contract.update!(current: true, status: :active, end_date: Date.new(2026, 12, 31))

    ContractExpiryProcessor.call(cutoff_date: Date.new(2027, 2, 1))

    assert contract.reload.expired?
    assert_not contract.current?
  end

  test "keeps open contracts current" do
    contract = athlete_contracts(:one)
    contract.update!(current: true, status: :active, end_date: nil)

    ContractExpiryProcessor.call(cutoff_date: Date.new(2027, 2, 1))

    assert contract.reload.active?
    assert contract.current?
  end
end
