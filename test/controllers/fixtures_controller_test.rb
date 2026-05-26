# frozen_string_literal: true

require "test_helper"

class FixturesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
    @career = careers(:one)
    manager_contracts(:one).update!(current: true, status: :active, role: :head_coach, end_date: nil)
    @fixture = fixtures(:one)
  end

  test "show fixture involving current club" do
    get career_fixture_path(@career, @fixture)

    assert_response :success
    assert_select ".match-team-name", @fixture.home_club.name
    assert_select ".match-team-name", @fixture.away_club.name
    assert_select ".match-score-card h1", false
    assert_select ".match-status-badge", @fixture.status.humanize
    assert_select "h2", "Home Formation"
    assert_select "h2", "Away Formation"
    assert_select "h2", "Manager Decisions"
    assert_select "h2", { text: "Timeline", count: 0 }
    assert_select "h2", "Standings"
    assert_select "button", "Start Matchday Clock"
    assert_select "button", "Simulate Match"
  end

  test "start pause and resume match clock" do
    post start_career_fixture_path(@career, @fixture)

    assert_redirected_to career_fixture_path(@career, @fixture)
    assert @fixture.reload.in_progress?
    assert @fixture.match_state.running?

    post pause_career_fixture_path(@career, @fixture)

    assert @fixture.match_state.reload.paused?

    post resume_career_fixture_path(@career, @fixture)

    assert @fixture.match_state.reload.running?
  end

  test "advance clock completes match at full time" do
    post start_career_fixture_path(@career, @fixture)

    6.times { post advance_clock_career_fixture_path(@career, @fixture) }

    assert @fixture.reload.completed?
    assert @fixture.match_state.reload.full_time?
  end

  test "simulate completes fixture" do
    @fixture.update!(status: :scheduled, home_goals: nil, away_goals: nil)
    @career.update!(current_date: "2026-01-01")

    post simulate_career_fixture_path(@career, @fixture)

    assert_redirected_to career_fixture_path(@career, @fixture)
    assert @fixture.reload.completed?
    assert @fixture.match_events.any?
    assert_equal @fixture.scheduled_on, @career.reload.current_date
  end

  test "show completed fixture links next match" do
    @fixture.update!(status: :completed, home_goals: 1, away_goals: 0)
    @fixture.match_events.create!(
      club: @fixture.home_club,
      athlete: athletes(:one),
      minute: 12,
      event_type: :goal,
      description: "Joao Pereira scored for Aurora FC."
    )
    @career.update!(current_date: @fixture.scheduled_on)

    get career_fixture_path(@career, @fixture)

    assert_response :success
    assert_select "h2", { text: "Timeline", count: 0 }
    assert_select "button", "Advance to next match"
  end

  test "show rejects fixture outside current club" do
    fixture = outside_fixture

    get career_fixture_path(@career, fixture)

    assert_response :not_found
  end

  private

  def outside_fixture
    third_club = countries(:two).clubs.create!(
      name: "Outside FC",
      short_name: "OUT",
      reputation: 1,
      status: :active
    )
    stadium = third_club.stadiums.create!(
      country: countries(:two),
      name: "Outside Park",
      city: "Outside",
      capacity: 1,
      pitch_quality: 1,
      ownership: :club_owned
    )
    tournament_editions(:two).fixtures.create!(
      home_club: third_club,
      away_club: clubs(:two),
      stadium:,
      scheduled_on: "2026-03-01",
      round: 2
    )
  end
end
