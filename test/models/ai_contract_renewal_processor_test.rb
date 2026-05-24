require "test_helper"

class AiContractRenewalProcessorTest < ActiveSupport::TestCase
  test "renews useful expiring contracts before cutoff" do
    club = clubs(:one)
    athlete = athletes(:one)
    athlete.update!(current_ability: 10)
    contract = athlete_contracts(:one)
    contract.update!(
      club:,
      athlete:,
      current: true,
      status: :active,
      end_date: Date.new(2026, 12, 31),
      wage: 100
    )
    club.club_finance.update!(wage_budget: 10_000)

    renewed = AiContractRenewalProcessor.call(cutoff_date: Date.new(2027, 1, 1))

    assert_includes renewed, contract
    assert_equal Date.new(2028, 1, 1), contract.reload.end_date
  end
end
