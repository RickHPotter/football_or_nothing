require "test_helper"

class TransferOfferProcessorTest < ActiveSupport::TestCase
  setup do
    @buyer = clubs(:one)
    @seller = clubs(:two)
    @athlete = athletes(:two)
    athlete_contracts(:two).update!(
      club: @seller,
      current: true,
      status: :active,
      end_date: nil,
      wage: 50,
      release_clause: 1_000
    )
    @buyer.club_finance.update!(cash_balance: 10_000, transfer_budget: 5_000, wage_budget: 5_000)
    @offer = TransferOffer.create!(
      athlete: @athlete,
      from_club: @seller,
      to_club: @buyer,
      offered_fee: 1_000,
      offered_wage: 100,
      offered_on: Date.new(2026, 2, 1),
      expires_on: Date.new(2026, 2, 15),
      status: :pending
    )
  end

  test "completes acceptable pending offer" do
    assert_difference "Transfer.count", 1 do
      TransferOfferProcessor.call(offer: @offer, transfer_date: Date.new(2026, 2, 2))
    end

    assert @offer.reload.completed?
    assert_equal @buyer, @athlete.reload.current_club
  end

  test "completes acceptable loan offer" do
    @offer.update!(
      transfer_type: :loan,
      offered_fee: 0,
      loan_ends_on: Date.new(2026, 8, 1)
    )

    assert_difference "Transfer.count", 1 do
      TransferOfferProcessor.call(offer: @offer, transfer_date: Date.new(2026, 2, 2))
    end

    assert @offer.reload.completed?
    assert @athlete.reload.current_athlete_contract.loan?
    assert_equal @buyer, @athlete.current_club
  end

  test "rejects offer below asking price" do
    @offer.update!(offered_fee: 500)

    assert_no_difference "Transfer.count" do
      assert_raises ActiveRecord::RecordInvalid do
        TransferOfferProcessor.call(offer: @offer, transfer_date: Date.new(2026, 2, 2))
      end
    end

    assert @offer.reload.pending?
  end
end
