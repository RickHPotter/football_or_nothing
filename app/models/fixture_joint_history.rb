# frozen_string_literal: true

class FixtureJointHistory
  def self.call(fixture:)
    new(fixture:).call
  end

  def initialize(fixture:)
    @fixture = fixture
  end

  def call
    (home_history + away_history)
      .uniq
      .sort_by { |history_fixture| [ history_fixture.scheduled_on, history_fixture.kickoff_minute, history_fixture.round, history_fixture.id ] }
  end

  private

  attr_reader :fixture

  def home_history
    FixtureHistory.call(fixture:, club: fixture.home_club)
  end

  def away_history
    FixtureHistory.call(fixture:, club: fixture.away_club)
  end
end
