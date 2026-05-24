require "test_helper"

class AiTransferPlannerTest < ActiveSupport::TestCase
  test "signs affordable free agent for weak position during transfer window" do
    club = clubs(:one)
    athlete = athletes(:two)
    athlete_contracts(:two).update!(current: false, status: :expired)
    athlete.update!(position: :striker, current_ability: 9, reputation: 1)
    club.club_finance.update!(cash_balance: 20_000, transfer_budget: 10_000, wage_budget: 10_000)

    assert_difference "Transfer.count", 1 do
      transfers = AiTransferPlanner.call(date: Date.new(2026, 1, 15), excluded_clubs: [ clubs(:two) ])
      assert_equal [ athlete ], transfers.map(&:athlete)
    end

    assert_equal club, athlete.reload.current_club
    assert athlete.transfers.last.free_transfer?
  end

  test "does not move excluded player club" do
    club = clubs(:one)
    club.club_finance.update!(cash_balance: 20_000, transfer_budget: 10_000, wage_budget: 10_000)

    assert_no_difference "Transfer.count" do
      AiTransferPlanner.call(date: Date.new(2026, 1, 15), excluded_clubs: [ club ])
    end
  end
end
