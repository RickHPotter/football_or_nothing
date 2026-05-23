require "test_helper"

class TransfersControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
    @career = careers(:one)
    manager_contracts(:one).update!(current: true, status: :active, role: :head_coach, end_date: nil)
    @club = clubs(:one)
    @target = athletes(:two)
    athlete_contracts(:two).update!(
      club: clubs(:two),
      current: true,
      status: :active,
      end_date: nil,
      wage: 50,
      release_clause: 1_000
    )
    @club.club_finance.update!(cash_balance: 10_000, transfer_budget: 5_000, wage_budget: 5_000)
  end

  test "shows transfer market" do
    get career_transfers_path(@career)

    assert_response :success
    assert_select "h1", "Transfer Market"
    assert_select "td", /#{@target.last_name}/
  end

  test "creates transfer offer from market" do
    assert_difference "TransferOffer.count", 1 do
      post career_transfers_path(@career), params: {
        athlete_id: @target.id,
        fee: 1_000,
        wage: 100
      }
    end

    assert_redirected_to career_transfers_path(@career)
    assert_equal @club, TransferOffer.last.to_club
    assert TransferOffer.last.pending?
  end

  test "completes pending transfer offer" do
    offer = TransferOffer.create!(
      athlete: @target,
      from_club: clubs(:two),
      to_club: @club,
      offered_fee: 1_000,
      offered_wage: 100,
      offered_on: @career.current_date,
      expires_on: @career.current_date + 14.days,
      status: :pending
    )

    assert_difference "Transfer.count", 1 do
      post complete_offer_career_transfer_path(@career, offer)
    end

    assert_redirected_to career_transfers_path(@career)
    assert_equal @club, @target.reload.current_club
    assert offer.reload.completed?
  end

  test "does not complete offer when budget is too low" do
    @club.club_finance.update!(transfer_budget: 500)
    offer = TransferOffer.create!(
      athlete: @target,
      from_club: clubs(:two),
      to_club: @club,
      offered_fee: 1_000,
      offered_wage: 100,
      offered_on: @career.current_date,
      expires_on: @career.current_date + 14.days,
      status: :pending
    )

    assert_no_difference "Transfer.count" do
      post complete_offer_career_transfer_path(@career, offer)
    end

    assert_redirected_to career_transfers_path(@career)
    assert offer.reload.pending?
  end

  test "does not create offer outside transfer window" do
    @career.update!(current_date: Date.new(2026, 7, 1))

    assert_no_difference "TransferOffer.count" do
      post career_transfers_path(@career), params: {
        athlete_id: @target.id,
        fee: 1_000,
        wage: 100
      }
    end

    assert_redirected_to career_transfers_path(@career)
  end
end
