# frozen_string_literal: true

class FixtureLineupSwapProcessor
  LIVE_CONTEXT = :live
  PRE_MATCH_CONTEXT = :pre_match

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
    return swap_pre_match if fixture.match_state.not_started? && matchday_session.nil?

    swap_live
  end

  private

  attr_reader :fixture, :club, :matchday_session, :from_lineup_athlete_id, :to_lineup_athlete_id

  def swap_pre_match
    LineupSwapper.call(lineup: fixture.lineup_for(club), from_lineup_athlete_id:, to_lineup_athlete_id:)
    PRE_MATCH_CONTEXT
  end

  def swap_live
    LiveLineupSwapProcessor.call(fixture:, club:, matchday_session:, from_lineup_athlete_id:, to_lineup_athlete_id:)
    LIVE_CONTEXT
  end
end
