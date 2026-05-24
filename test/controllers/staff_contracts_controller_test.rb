require "test_helper"

class StaffContractsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
    @career = careers(:one)
    manager_contracts(:one).update!(current: true, status: :active, role: :head_coach, end_date: nil)
    clubs(:one).club_finance.update!(wage_budget: 10_000)
    @staff = StaffMember.create!(
      country: countries(:one),
      first_name: "Lia",
      last_name: "Ferreira",
      role: :scout,
      reputation: 6,
      coaching: 4,
      fitness: 4,
      scouting: 13,
      judging_ability: 12,
      judging_potential: 12,
      physiotherapy: 3,
      discipline: 8,
      motivation: 8
    )
  end

  test "shows staff screen" do
    get career_staff_contracts_path(@career)

    assert_response :success
    assert_select "h1", "Staff"
  end

  test "hires staff from market" do
    assert_difference "StaffContract.count", 1 do
      post career_staff_contracts_path(@career), params: {
        staff_member_id: @staff.id,
        wage: 500
      }
    end

    assert_redirected_to career_staff_contracts_path(@career)
    assert_equal clubs(:one), @staff.reload.current_club
  end
end
