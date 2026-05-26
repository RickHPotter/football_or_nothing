# frozen_string_literal: true

class MatchdayClock
  MATCH_MINUTES = 90

  def self.start(session, now: Time.current)
    new(session, now:).start
  end

  def self.refresh(session, now: Time.current)
    new(session, now:).refresh
  end

  def self.pause(session, now: Time.current)
    new(session, now:).pause
  end

  def self.resume(session, now: Time.current)
    new(session, now:).resume
  end

  def initialize(session, now:)
    @session = session
    @now = now
  end

  def start
    return session if session.running? || session.completed?

    session.update!(
      status: :running,
      period: period_for(session.minute),
      started_at: now,
      paused_at: nil
    )
    session
  end

  def refresh
    return session unless session.running?

    apply_elapsed!(current_elapsed_seconds)
  end

  def pause
    elapsed_seconds = current_elapsed_seconds
    apply_elapsed!(elapsed_seconds)
    return session unless session.running?

    session.update!(
      status: :paused,
      paused_at: now,
      elapsed_seconds:
    )
    session
  end

  def resume
    return session unless session.paused?

    session.update!(
      status: :running,
      period: period_for(session.minute),
      started_at: now,
      paused_at: nil
    )
    session
  end

  private

  attr_reader :session, :now

  def apply_elapsed!(elapsed_seconds)
    minute = minute_for(elapsed_seconds)
    session.update!(
      status: minute >= MATCH_MINUTES ? :completed : :running,
      period: period_for(minute),
      minute:,
      elapsed_seconds: [ elapsed_seconds, session.total_duration_seconds ].min
    )
    session
  end

  def current_elapsed_seconds
    return session.elapsed_seconds unless session.started_at

    session.elapsed_seconds + [ (now - session.started_at).floor, 0 ].max
  end

  def minute_for(elapsed_seconds)
    ((elapsed_seconds.to_f / session.total_duration_seconds) * MATCH_MINUTES).floor.clamp(0, MATCH_MINUTES)
  end

  def period_for(minute)
    case minute
    when 0...45 then :first_half
    when 45 then :half_time
    when 46...90 then :second_half
    else :full_time
    end
  end
end
