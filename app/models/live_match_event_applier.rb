# frozen_string_literal: true

class LiveMatchEventApplier
  def self.call(...)
    new(...).call
  end

  def initialize(session:, minute: nil, now: Time.current)
    @session = session
    @minute = minute || session.minute
    @now = now
  end

  def call
    MatchdayEvent.transaction do
      session.matchday_events.due(minute).each { |event| apply_event(event) }
    end
  end

  private

  attr_reader :session, :minute, :now

  def apply_event(event)
    return if event.applied_at?

    event.fixture.match_events.create!(
      club: event.club,
      athlete: event.athlete,
      minute: event.minute,
      event_type: event.event_type,
      description: event.description
    )
    event.update!(applied_at: now)
  end
end
