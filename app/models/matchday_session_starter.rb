# frozen_string_literal: true

class MatchdaySessionStarter
  def self.call(...)
    new(...).call
  end

  def initialize(career:, fixture:)
    @career = career
    @fixture = fixture
  end

  def call
    MatchdaySession.find_or_create_by!(
      career:,
      tournament_edition: fixture.tournament_edition,
      scheduled_on: fixture.scheduled_on,
      round: fixture.round
    ) do |session|
      session.focused_fixture = fixture
    end
  end

  private

  attr_reader :career, :fixture
end
