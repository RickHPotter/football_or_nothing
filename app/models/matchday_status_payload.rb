# frozen_string_literal: true

class MatchdayStatusPayload
  def self.call(session)
    new(session).call
  end

  def initialize(session)
    @session = session
  end

  def call
    {
      status: session.status.humanize,
      status_key: session.status,
      minute: session.minute,
      fixtures: fixture_payloads
    }
  end

  private

  attr_reader :session

  def fixture_payloads
    session.fixtures.index_with do |fixture|
      {
        scoreline: scorelines.fetch(fixture),
        events: event_payloads(fixture)
      }
    end.transform_keys(&:id)
  end

  def scorelines
    MatchdayScoreboard.call(session)
  end

  def event_payloads(fixture)
    fixture.match_events.includes(:club, :athlete).order(:minute, :id).last(1).map do |event|
      {
        minute: event.minute,
        event_type: event.event_type.humanize,
        description: event.description
      }
    end
  end
end
