# frozen_string_literal: true

require "test_helper"

class MatchdaySessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
    @career = careers(:one)
    manager_contracts(:one).update!(current: true, status: :active, role: :head_coach, end_date: nil)
    @fixture = fixtures(:one)
  end

  test "starts a matchday session for the selected fixture" do
    assert_difference "MatchdaySession.count", 1 do
      post start_matchday_career_fixture_path(@career, @fixture)
    end

    assert_redirected_to career_fixture_path(@career, @fixture)
    session = MatchdaySession.last
    assert session.running?
    assert_equal @fixture, session.focused_fixture
    assert session.matchday_events.any?
  end

  test "pauses a running matchday and focuses selected fixture" do
    session = MatchdaySessionStarter.call(career: @career, fixture: @fixture)
    MatchdayClock.start(session, now: Time.current)

    patch pause_matchday_career_fixture_path(@career, @fixture)

    assert_redirected_to career_fixture_path(@career, @fixture)
    assert session.reload.paused?
    assert_equal @fixture, session.focused_fixture
  end

  test "shows live matchday fixtures while session is running" do
    other_fixture = create_simultaneous_fixture
    session = MatchdaySessionStarter.call(career: @career, fixture: @fixture)
    MatchdayClock.start(session, now: Time.current)

    get career_fixture_path(@career, @fixture)

    assert_response :success
    assert_select "h2", "Live Matchday"
    assert_select ".matchday-fixture-card", 2
    assert_select ".matchday-fixture-card.is-managed", 1
    assert_select ".matchday-fixture-card", text: /#{other_fixture.home_club.short_name}/
    assert_select "input[type='submit'][value='Update tactics']", 0
    assert_select ".empty-state", /Pause matchday to make decisions/
  end

  test "shows manager controls when matchday is paused on managed fixture" do
    session = MatchdaySessionStarter.call(career: @career, fixture: @fixture)
    MatchdayClock.start(session, now: Time.current)
    MatchdayClock.pause(session, now: Time.current + 2.seconds)

    get career_fixture_path(@career, @fixture)

    assert_response :success
    assert_select "input[type='submit'][value='Update tactics']"
  end

  test "focuses a simultaneous fixture outside manager club" do
    other_fixture = create_simultaneous_fixture
    session = MatchdaySessionStarter.call(career: @career, fixture: @fixture)
    MatchdayClock.start(session, now: Time.current)

    patch focus_matchday_career_fixture_path(@career, other_fixture)

    assert_redirected_to career_fixture_path(@career, other_fixture)
    assert session.reload.paused?
    assert_equal other_fixture, session.focused_fixture
  end

  test "keeps manager controls hidden on neutral focused fixture" do
    other_fixture = create_simultaneous_fixture
    session = MatchdaySessionStarter.call(career: @career, fixture: @fixture)
    MatchdayClock.start(session, now: Time.current)
    MatchdayClock.pause(session, now: Time.current + 2.seconds)
    session.update!(focused_fixture: other_fixture)

    get career_fixture_path(@career, other_fixture)

    assert_response :success
    assert_select "input[type='submit'][value='Update tactics']", 0
    assert_select ".empty-state", /Manager decisions are only available for your club/
  end

  test "finalizes running matchday when server clock reaches full time" do
    session = MatchdaySessionStarter.call(career: @career, fixture: @fixture)
    travel_to Time.zone.local(2026, 2, 1, 12, 0, 0) do
      MatchdayClock.start(session, now: 30.seconds.ago)

      get career_fixture_path(@career, @fixture)
    end

    assert_response :success
    assert session.reload.completed?
    assert @fixture.reload.completed?
    assert @fixture.match_state.full_time?
    assert session.matchday_standing_snapshots.where.not(position_after: nil).exists?
  end

  test "resumes a paused matchday" do
    session = MatchdaySessionStarter.call(career: @career, fixture: @fixture)
    MatchdayClock.start(session)
    MatchdayClock.pause(session)

    patch resume_matchday_career_fixture_path(@career, @fixture)

    assert_redirected_to career_fixture_path(@career, @fixture)
    assert session.reload.running?
  end

  test "requires an existing matchday before pausing" do
    patch pause_matchday_career_fixture_path(@career, @fixture)

    assert_redirected_to career_fixture_path(@career, @fixture)
    assert_equal "Start the matchday clock first.", flash[:alert]
  end

  private

  def create_simultaneous_fixture
    home_club = create_club("Parallel Home", "PARH")
    away_club = create_club("Parallel Away", "PARA")
    tournament_editions(:one).fixtures.create!(
      home_club:,
      away_club:,
      stadium: stadium_for(home_club),
      scheduled_on: @fixture.scheduled_on,
      kickoff_minute: @fixture.kickoff_minute,
      round: @fixture.round
    )
  end

  def create_club(name, short_name)
    countries(:one).clubs.create!(
      name:,
      short_name:,
      reputation: 1,
      status: :active
    )
  end

  def stadium_for(club)
    club.stadiums.create!(
      country: club.country,
      name: "#{club.name} Ground",
      city: "Brasilia",
      capacity: 10_000,
      pitch_quality: 10,
      ownership: :club_owned
    )
  end
end
