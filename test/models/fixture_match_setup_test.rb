require "test_helper"

class FixtureMatchSetupTest < ActiveSupport::TestCase
  test "creates match state and lineups for both clubs" do
    fixture = fixtures(:one)

    fixture.ensure_match_setup!

    assert fixture.match_state.not_started?
    assert_equal 2, fixture.lineups.count
    assert_equal [ fixture.away_club, fixture.home_club ].map(&:id).sort, fixture.lineups.map(&:club_id).sort
    assert fixture.lineups.all? { |lineup| lineup.lineup_athletes.any? }
  end

  test "does not duplicate setup" do
    fixture = fixtures(:one)

    fixture.ensure_match_setup!

    assert_no_difference [ "MatchState.count", "Lineup.count", "LineupAthlete.count" ] do
      fixture.ensure_match_setup!
    end
  end
end
