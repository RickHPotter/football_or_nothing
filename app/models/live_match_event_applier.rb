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
      apply_ai_substitutions
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

  def apply_ai_substitutions
    session.fixtures.each do |fixture|
      ai_clubs_for(fixture).each { |club| AiSubstitutionPlanner.call(fixture:, club:, minute:) }
    end
  end

  def ai_clubs_for(fixture)
    [ fixture.home_club, fixture.away_club ].reject { |club| club == managed_club }
  end

  def managed_club
    @managed_club ||= session.career.manager&.current_club
  end
end
