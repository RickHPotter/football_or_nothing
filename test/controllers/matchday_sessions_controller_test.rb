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
end
