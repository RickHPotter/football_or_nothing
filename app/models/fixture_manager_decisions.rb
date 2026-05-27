# frozen_string_literal: true

class FixtureManagerDecisions
  def initialize(fixture:, club:, lineup:, matchday_session:)
    @fixture = fixture
    @club = club
    @lineup = lineup
    @matchday_session = matchday_session
  end

  def available?
    return false if fixture.completed? || lineup.nil?
    return true unless matchday_session

    matchday_session.paused?
  end

  def message
    return "Match completed." if fixture.completed?
    return "Pause matchday to make decisions." if matchday_session&.running?
    return "Manager decisions are only available for your club." unless fixture.involves?(club)

    "No managed lineup available."
  end

  private

  attr_reader :fixture, :club, :lineup, :matchday_session
end
