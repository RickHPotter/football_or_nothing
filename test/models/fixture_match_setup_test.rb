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

  test "prefers available athletes for lineup setup" do
    fixture = fixtures(:one)
    injured = athletes(:one)
    available = Athlete.create!(
      country: clubs(:one).country,
      first_name: "Ready",
      last_name: "Player",
      position: :central_midfielder,
      preferred_foot: :right,
      current_ability: 5,
      potential_ability: 5,
      reputation: 1,
      morale: 50,
      condition: 100,
      status: :active,
      **Athlete::ATTRIBUTES.index_with { 5 }
    )
    athlete_contracts(:one).update!(club: clubs(:one), athlete: injured, current: true, status: :active, end_date: nil)
    injured.update!(status: :injured, injury_until: fixture.scheduled_on + 7.days)
    clubs(:one).athlete_contracts.create!(athlete: available, start_date: fixture.scheduled_on, wage: 100, current: true, status: :active)

    fixture.ensure_match_setup!

    lineup_athletes = fixture.lineup_for(clubs(:one)).athletes
    assert_includes lineup_athletes, available
    assert_not_includes lineup_athletes, injured
  end
end
