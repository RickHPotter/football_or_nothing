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

    complete_session!(session)
    MatchdaySessionFinalizer.call(session:, focused_fixture: fixture)

    session
  end

  private

  attr_reader :career, :fixture

  def complete_session!(session)
    session.update!(
      focused_fixture: fixture,
      status: :completed,
      period: :full_time,
      minute: 90,
      elapsed_seconds: session.total_duration_seconds
    )
  end
end
