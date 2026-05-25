# frozen_string_literal: true

require "test_helper"

class TournamentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
    @career = careers(:one)
  end

  test "index lists tournaments" do
    get career_tournaments_path(@career)

    assert_response :success
    assert_select "h1", "Tournaments"
    assert_select "a", tournaments(:one).name
    assert_select "td", countries(:one).name
  end

  test "show displays tournament edition standings and fixtures" do
    get career_tournament_path(@career, tournaments(:one))

    assert_response :success
    assert_select "h1", tournaments(:one).name
    assert_select "h2", "Standings"
    assert_select "h2", "Fixtures"
    assert_select "td", clubs(:one).name
  end
end
