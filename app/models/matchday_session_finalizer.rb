# frozen_string_literal: true

class MatchdaySessionFinalizer
  def self.call(...)
    new(...).call
  end

  def initialize(session:, focused_fixture: nil)
    @session = session
    @focused_fixture = focused_fixture || session.focused_fixture
  end

  def call
    return session unless session.completed?
    return session if finalized?

    record_before_standings
    session.fixtures.each { |fixture| finalize_fixture(fixture) }
    record_after_standings
    advance_career!
    session.update!(focused_fixture:) if focused_fixture

    session
  end

  private

  attr_reader :session, :focused_fixture

  def finalized?
    session.fixtures.all?(&:completed?) && after_standings_recorded?
  end

  def finalize_fixture(fixture)
    MatchSimulator.new(fixture, preserve_events: true).call
    fixture.match_state&.full_time!
  end

  def record_before_standings
    return if before_standings_recorded?

    MatchdayStandingSnapshotRecorder.call(session:, stage: :before)
  end

  def record_after_standings
    MatchdayStandingSnapshotRecorder.call(session:, stage: :after)
  end

  def before_standings_recorded?
    session.matchday_standing_snapshots.where.not(position_before: nil).exists?
  end

  def after_standings_recorded?
    session.matchday_standing_snapshots.where.not(position_after: nil).exists?
  end

  def advance_career!
    career = session.career
    career.update!(current_date: session.scheduled_on) if career.current_date < session.scheduled_on
  end
end
