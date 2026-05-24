require "test_helper"

class LoanExpiryProcessorTest < ActiveSupport::TestCase
  setup do
    @parent_club = clubs(:two)
    @loan_club = clubs(:one)
    @athlete = athletes(:two)
    @parent_contract = athlete_contracts(:two)
    @parent_contract.update!(
      club: @parent_club,
      current: false,
      status: :active,
      end_date: nil,
      wage: 50,
      release_clause: 1_000
    )
    @loan_contract = @loan_club.athlete_contracts.create!(
      athlete: @athlete,
      start_date: Date.new(2026, 2, 1),
      end_date: Date.new(2026, 8, 1),
      wage: 100,
      loan: true,
      loan_ends_on: Date.new(2026, 8, 1),
      parent_athlete_contract: @parent_contract,
      status: :active,
      current: true
    )
  end

  test "returns expired loan player to parent club" do
    LoanExpiryProcessor.call(cutoff_date: Date.new(2026, 8, 2))

    assert @loan_contract.reload.expired?
    assert_not @loan_contract.current?
    assert @parent_contract.reload.active?
    assert @parent_contract.current?
    assert_equal @parent_club, @athlete.reload.current_club
  end

  test "keeps loan active until cutoff passes end date" do
    LoanExpiryProcessor.call(cutoff_date: Date.new(2026, 8, 1))

    assert @loan_contract.reload.active?
    assert @loan_contract.current?
    assert_not @parent_contract.reload.current?
  end
end
