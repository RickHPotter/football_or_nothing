require "test_helper"

class TransferProcessorTest < ActiveSupport::TestCase
  setup do
    @buyer = clubs(:one)
    @seller = clubs(:two)
    @athlete = athletes(:two)
    @contract = athlete_contracts(:two)
    @contract.update!(
      club: @seller,
      current: true,
      status: :active,
      end_date: nil,
      wage: 50,
      release_clause: 1_000
    )
    @buyer.club_finance.update!(cash_balance: 10_000, transfer_budget: 5_000, wage_budget: 5_000)
    @seller.club_finance.update!(cash_balance: 1_000)
  end

  test "completes permanent transfer and preserves contract history" do
    transfer = nil

    assert_difference "Transfer.count", 1 do
      transfer = TransferProcessor.call(
        athlete: @athlete,
        to_club: @buyer,
        transfer_date: Date.new(2026, 2, 1),
        fee: 1_000,
        wage: 100
      )
    end

    assert transfer.permanent?
    assert transfer.completed?
    assert_equal @seller, transfer.from_club
    assert @contract.reload.terminated?
    assert_not @contract.current?
    assert_equal Date.new(2026, 1, 31), @contract.end_date
    assert_equal @buyer, @athlete.reload.current_club
    assert_equal 4_000, @buyer.club_finance.reload.transfer_budget
    assert_equal 9_000, @buyer.club_finance.cash_balance
    assert_equal 2_000, @seller.club_finance.reload.cash_balance
  end

  test "completes free transfer for athlete without current contract" do
    @contract.update!(current: false, status: :terminated, end_date: Date.new(2026, 1, 1))

    transfer = TransferProcessor.call(
      athlete: @athlete,
      to_club: @buyer,
      transfer_date: Date.new(2026, 2, 1),
      fee: 0,
      wage: 100
    )

    assert transfer.free_transfer?
    assert_nil transfer.from_club
    assert_equal @buyer, @athlete.reload.current_club
  end

  test "rejects transfer above budget" do
    @buyer.club_finance.update!(transfer_budget: 500)

    assert_no_difference "Transfer.count" do
      assert_raises ActiveRecord::RecordInvalid do
        TransferProcessor.call(
          athlete: @athlete,
          to_club: @buyer,
          transfer_date: Date.new(2026, 2, 1),
          fee: 1_000,
          wage: 100
        )
      end
    end
  end
end
