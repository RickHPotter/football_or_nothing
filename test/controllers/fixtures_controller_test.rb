# frozen_string_literal: true

require "test_helper"

class FixturesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
    @career = careers(:one)
    manager_contracts(:one).update!(current: true, status: :active, role: :head_coach, end_date: nil)
    @fixture = fixtures(:one)
    TournamentParticipation.find_or_create_by!(tournament_edition: @fixture.tournament_edition, club: @fixture.away_club).update!(
      status: :active,
      position: 2
    )
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
    assert_select "h2", { text: "History", count: 2 }
    assert_select "th", "#"
    assert_select "li.font-bold", { text: /#{@fixture.home_club.name} vs #{@fixture.away_club.name}/, count: 2 }
    assert_select "tr.font-bold", 2
    assert_select "button", "Start Matchday Clock"
    assert_select "button", "Simulate Match"
  end

  test "layout navigation keeps current career from nested route" do
    Current.user.careers.create!(name: "Newer Career", current_date: Date.new(2026, 1, 1), status: :active)

    get career_fixture_path(@career, @fixture, details: true)

    assert_response :success
    assert_select ".game-nav a[href='#{career_path(@career)}']", text: "Career"
    assert_select ".game-nav a[href='#{career_club_path(@career)}']", text: "Club"
  end

  test "show fixture history uses two past current and two next matches" do
    create_history_fixture(home_club: @fixture.home_club, away_club: create_club("Home Past One"), scheduled_on: "2026-01-18", round: 1)
    create_history_fixture(home_club: create_club("Home Past Two"), away_club: @fixture.home_club, scheduled_on: "2026-01-25", round: 2)
    create_history_fixture(home_club: @fixture.home_club, away_club: create_club("Home Next One"), scheduled_on: "2026-02-08", round: 4)
    create_history_fixture(home_club: create_club("Home Next Two"), away_club: @fixture.home_club, scheduled_on: "2026-02-15", round: 5)
    create_history_fixture(home_club: @fixture.away_club, away_club: create_club("Away Past One"), scheduled_on: "2026-01-18", round: 1)
    create_history_fixture(home_club: create_club("Away Past Two"), away_club: @fixture.away_club, scheduled_on: "2026-01-25", round: 2)
    create_history_fixture(home_club: @fixture.away_club, away_club: create_club("Away Next One"), scheduled_on: "2026-02-08", round: 4)
    create_history_fixture(home_club: create_club("Away Next Two"), away_club: @fixture.away_club, scheduled_on: "2026-02-15", round: 5)

    get career_fixture_path(@career, @fixture)

    assert_response :success
    assert_select ".panel", text: /History/, count: 2
    assert_select ".panel ol", count: 2 do |lists|
      lists.each do |list|
        assert_select list, "li", 5
        assert_select list, "li.font-bold", 1
      end
    end
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
    assert_nil flash[:notice]
    assert @fixture.reload.completed?
    assert @fixture.match_events.any?
    assert_equal @fixture.scheduled_on, @career.reload.current_date
  end

  test "simulate completes the whole simultaneous matchday" do
    simultaneous_fixture = tournament_editions(:one).fixtures.create!(
      home_club: @fixture.away_club,
      away_club: @fixture.home_club,
      stadium: stadiums(:two),
      scheduled_on: @fixture.scheduled_on,
      kickoff_minute: @fixture.kickoff_minute,
      round: @fixture.round
    )

    post simulate_career_fixture_path(@career, @fixture)

    assert_redirected_to career_fixture_path(@career, @fixture)
    assert @fixture.reload.completed?
    assert simultaneous_fixture.reload.completed?
    assert @fixture.match_state.full_time?
    assert simultaneous_fixture.match_state.full_time?
    assert_not_equal "0-0", @fixture.scoreline
    session = MatchdaySession.find_by!(
      career: @career,
      tournament_edition: @fixture.tournament_edition,
      scheduled_on: @fixture.scheduled_on,
      round: @fixture.round
    )
    assert session.completed?
    assert_equal 2, session.matchday_standing_snapshots.count

    get career_fixture_path(@career, @fixture, details: true)

    assert_response :success
    assert_select "h2", { text: "Live Matchday", count: 0 }
    assert_select ".matchday-fixture-card", 0
    assert_select "th", "Move"
    assert_select "a", "Back to matchday"
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
    assert_select "h2", "Timeline"
    assert_select "h2", { text: "Manager Decisions", count: 0 }
    assert_select "li", /Joao Pereira scored/
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

  def create_history_fixture(home_club:, away_club:, scheduled_on:, round:)
    tournament_editions(:one).fixtures.create!(
      home_club:,
      away_club:,
      stadium: @fixture.stadium,
      scheduled_on:,
      kickoff_minute: @fixture.kickoff_minute,
      round:
    )
  end

  def create_club(name)
    countries(:one).clubs.create!(
      name:,
      short_name: name.split.map(&:first).join,
      reputation: 1,
      status: :active
    )
  end
end
