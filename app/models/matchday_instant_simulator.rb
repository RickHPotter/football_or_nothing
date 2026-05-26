# frozen_string_literal: true

class MatchdayInstantSimulator
  def self.call(...)
    new(...).call
  end

  def initialize(career:, fixture:)
    @career = career
    @fixture = fixture
  end

  def call
    session = MatchdaySessionStarter.call(career:, fixture:)

    MatchdayStandingSnapshotRecorder.call(session:, stage: :before)
    session.fixtures.each { |matchday_fixture| simulate_fixture(matchday_fixture) }
    MatchdayStandingSnapshotRecorder.call(session:, stage: :after)
    finish_session!(session)
    advance_career!

    session
  end

  private

  attr_reader :career, :fixture

  def simulate_fixture(matchday_fixture)
    MatchSimulator.call(matchday_fixture)
    matchday_fixture.match_state&.full_time!
  end

  def finish_session!(session)
    session.update!(
      focused_fixture: fixture,
      status: :completed,
      period: :full_time,
      minute: 90,
      elapsed_seconds: session.total_duration_seconds
    )
  end

  def advance_career!
    career.update!(current_date: fixture.scheduled_on) if career.current_date < fixture.scheduled_on
  end
end
