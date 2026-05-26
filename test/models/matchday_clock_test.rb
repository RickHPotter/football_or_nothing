# frozen_string_literal: true

require "test_helper"

class MatchdayClockTest < ActiveSupport::TestCase
  test "starts a not started session from server time" do
    session = matchday_session
    now = Time.zone.local(2026, 2, 1, 12, 0, 0)

    MatchdayClock.start(session, now:)

    assert session.reload.running?
    assert session.first_half?
    assert_equal 0, session.minute
    assert_equal now, session.started_at
  end

  test "refresh calculates minute from elapsed server time" do
    session = matchday_session
    now = Time.zone.local(2026, 2, 1, 12, 0, 0)
    MatchdayClock.start(session, now:)

    MatchdayClock.refresh(session, now: now + 5.seconds)

    assert_equal 22, session.reload.minute
    assert session.first_half?
  end

  test "refresh reaches half time and full time from duration" do
    session = matchday_session
    now = Time.zone.local(2026, 2, 1, 12, 0, 0)
    MatchdayClock.start(session, now:)

    MatchdayClock.refresh(session, now: now + 10.seconds)

    assert_equal 45, session.reload.minute
    assert session.half_time?

    MatchdayClock.refresh(session, now: now + 20.seconds)

    assert_equal 90, session.reload.minute
    assert session.completed?
    assert session.full_time?
  end

  test "pause freezes elapsed time and resume continues from stored elapsed time" do
    session = matchday_session
    now = Time.zone.local(2026, 2, 1, 12, 0, 0)
    MatchdayClock.start(session, now:)
    MatchdayClock.pause(session, now: now + 5.seconds)

    assert session.reload.paused?
    assert_equal 22, session.minute
    assert_equal 5, session.elapsed_seconds

    MatchdayClock.resume(session, now: now + 15.seconds)
    MatchdayClock.refresh(session, now: now + 20.seconds)

    assert_equal 45, session.reload.minute
    assert session.half_time?
    assert_equal 10, session.elapsed_seconds
  end

  private

  def matchday_session
    MatchdaySessionStarter.call(career: careers(:one), fixture: fixtures(:one))
  end
end
