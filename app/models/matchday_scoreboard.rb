# frozen_string_literal: true

class MatchdayScoreboard
  def self.call(session)
    new(session).call
  end

  def initialize(session)
    @session = session
  end

  def call
    session.fixtures.index_with { |fixture| scoreline_for(fixture) }
  end

  private

  attr_reader :session

  def scoreline_for(fixture)
    return fixture.scoreline if fixture.completed?

    "#{goals_for(fixture, fixture.home_club)}-#{goals_for(fixture, fixture.away_club)}"
  end

  def goals_for(fixture, club)
    fixture.match_events.goal.where(club:).count
  end
end
