# frozen_string_literal: true

require "test_helper"

class AthletesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
    @career = careers(:one)
    manager_contracts(:one).update!(current: true, status: :active, role: :head_coach, end_date: nil)
    athlete_contracts(:one).update!(current: true, status: :active, end_date: nil)
  end

  test "show current squad athlete" do
    get career_athlete_path(@career, athletes(:one))

    assert_response :success
    assert_select "h1", "#{athletes(:one).first_name} #{athletes(:one).last_name}"
    assert_select "h2", "Contract"
    assert_select "h2", "Stats"
    assert_select "h2", "Attributes"
  end

  test "show rejects athlete outside current squad" do
    get career_athlete_path(@career, athletes(:two))

    assert_response :not_found
  end
end
