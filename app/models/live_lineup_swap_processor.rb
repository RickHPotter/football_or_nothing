# frozen_string_literal: true

class LiveLineupSwapProcessor
  class Error < StandardError; end

  def self.call(...)
    new(...).call
  end

  def initialize(fixture:, club:, matchday_session:, from_lineup_athlete_id:, to_lineup_athlete_id:)
    @fixture = fixture
    @club = club
    @matchday_session = matchday_session
    @from_lineup_athlete_id = from_lineup_athlete_id
    @to_lineup_athlete_id = to_lineup_athlete_id
  end

  def call
    validate_context!
    validate_starters!

    LineupSwapper.call(lineup:, from_lineup_athlete_id:, to_lineup_athlete_id:)
  end

  private

  attr_reader :fixture, :club, :matchday_session, :from_lineup_athlete_id, :to_lineup_athlete_id

  def validate_context!
    raise Error, "Lineups can only be changed before kickoff." unless matchday_session
    raise Error, "Pause matchday before changing positions." unless matchday_session.paused?
    raise Error, "Lineup changes are only available for your club." unless fixture.involves?(club)
    raise Error, "Match is already completed." if fixture.completed?
    raise Error, "This fixture is not part of the current matchday." unless matchday_session.includes_fixture?(fixture)
  end

  def validate_starters!
    lineup.lineup_athletes.starters.find(from_lineup_athlete_id)
    lineup.lineup_athletes.starters.find(to_lineup_athlete_id)
  end

  def lineup
    @lineup ||= fixture.lineup_for(club) || raise(Error, "No managed lineup available.")
  end
end
