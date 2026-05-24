# frozen_string_literal: true

require "test_helper"

class ScoutingAssignmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
    @career = careers(:one)
    manager_contracts(:one).update!(current: true, status: :active, role: :head_coach, end_date: nil)
  end

  test "shows scouting screen" do
    get career_scouting_assignments_path(@career)

    assert_response :success
    assert_select "h1", "Scouting"
  end

  test "creates scouting assignment" do
    assert_difference "ScoutingAssignment.count", 1 do
      post career_scouting_assignments_path(@career), params: {
        scouting_assignment: {
          country_id: countries(:one).id,
          position: "striker",
          focus: "bargain"
        }
      }
    end

    assert_redirected_to career_scouting_assignments_path(@career)
    assignment = ScoutingAssignment.last
    assert assignment.bargain?
    assert assignment.position_striker?
  end
end
