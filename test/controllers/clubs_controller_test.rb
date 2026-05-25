# frozen_string_literal: true

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
    assert_select "h2", "Top scorers"
    assert_select "h2", "Trophies"
    assert_select "h2", "Club seasons"
    assert_select "h2", "Squad"
    assert_select "a", "Transfer market"
    assert_select "td", fixtures(:one).tournament_edition.name
    assert_select "td", tournament_participations(:one).points.to_s
    assert_select "a", fixtures(:one).home_club.name
    assert_select "a", "#{athletes(:one).first_name} #{athletes(:one).last_name}"
  end

  test "index lists browseable clubs and job eligibility" do
    manager_contracts(:one).update!(current: false)
    @career.manager.update!(status: :unemployed, reputation: 1)

    get career_browse_clubs_path(@career)

    assert_response :success
    assert_select "h1", "Clubs"
    assert_select "a", @club.name
    assert_select "button", "Take job"
  end

  test "show can browse a specific club" do
    get career_browse_club_path(@career, clubs(:two))

    assert_response :success
    assert_select "h1", clubs(:two).name
    assert_select "a", "All clubs"
  end

  test "show redirects unemployed manager back to career" do
    manager_contracts(:one).update!(current: false)

    get career_club_path(@career)

    assert_redirected_to career_path(@career)
  end
end
