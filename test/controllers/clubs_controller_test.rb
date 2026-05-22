require "test_helper"

class ClubsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
    @career = careers(:one)
    @club = clubs(:one)
    manager_contracts(:one).update!(current: true, status: :active, role: :head_coach, end_date: nil)
    athlete_contracts(:one).update!(current: true, status: :active, end_date: nil)
  end

  test "show current club dashboard" do
    get career_club_path(@career)

    assert_response :success
    assert_select "h1", @club.name
    assert_select "h2", "Finances"
    assert_select "h2", "Stadium"
    assert_select "h2", "Fixtures"
    assert_select "h2", "Standings"
    assert_select "h2", "Squad"
    assert_select "td", fixtures(:one).tournament_edition.name
    assert_select "td", tournament_participations(:one).points.to_s
    assert_select "a", fixtures(:one).home_club.name
    assert_select "a", "#{athletes(:one).first_name} #{athletes(:one).last_name}"
  end

  test "show redirects unemployed manager back to career" do
    manager_contracts(:one).update!(current: false)

    get career_club_path(@career)

    assert_redirected_to career_path(@career)
  end
end
