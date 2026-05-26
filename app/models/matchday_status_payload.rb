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
    scorelines.transform_keys(&:id).transform_values { |scoreline| { scoreline: } }
  end

  def scorelines
    MatchdayScoreboard.call(session)
  end
end
