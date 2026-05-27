# frozen_string_literal: true

require "test_helper"

class FixtureMatchSetupTest < ActiveSupport::TestCase
  test "creates match state and lineups for both clubs" do
    fixture = fixtures(:one)

    fixture.ensure_match_setup!

    assert fixture.match_state.not_started?
    assert_equal 2, fixture.lineups.count
    assert_equal [ fixture.away_club, fixture.home_club ].map(&:id).sort, fixture.lineups.map(&:club_id).sort
    assert(fixture.lineups.all? { |lineup| lineup.lineup_athletes.any? })
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
    available = create_athlete(clubs(:one), "Ready", "Player", :central_midfielder, 5)
    athlete_contracts(:one).update!(club: clubs(:one), athlete: injured, current: true, status: :active, end_date: nil)
    injured.update!(status: :injured, injury_until: fixture.scheduled_on + 7.days)
    clubs(:one).athlete_contracts.create!(athlete: available, start_date: fixture.scheduled_on, wage: 100, current: true, status: :active)

    fixture.ensure_match_setup!

    lineup_athletes = fixture.lineup_for(clubs(:one)).athletes
    assert_includes lineup_athletes, available
    assert_not_includes lineup_athletes, injured
  end

  test "builds a realistic lineup when squad has many goalkeepers" do
    fixture = fixtures(:one)
    club = fixture.home_club
    club.athlete_contracts.update_all(current: false)

    7.times { |index| create_contracted_athlete(club, "Keeper", index, :goalkeeper, 8 - index) }
    2.times { |index| create_contracted_athlete(club, "Center Back", index, :center_back, 10 - index) }
    2.times { |index| create_contracted_athlete(club, "Full Back", index, :full_back, 10 - index) }
    4.times { |index| create_contracted_athlete(club, "Midfielder", index, :central_midfielder, 10 - index) }
    2.times { |index| create_contracted_athlete(club, "Forward", index, :striker, 10 - index) }

    fixture.ensure_match_setup!

    lineup = fixture.lineup_for(club)
    starters = lineup.starters.map(&:athlete)
    bench = lineup.bench.map(&:athlete)

    assert_equal 11, starters.length
    assert_equal 1, starters.count(&:goalkeeper?)
    assert_operator bench.count(&:goalkeeper?), :<=, 1
  end

  test "persists formation slot keys for starters and bench" do
    fixture = fixtures(:one)
    club = fixture.home_club
    club.athlete_contracts.update_all(current: false)
    add_balanced_squad_depth(club)

    fixture.ensure_match_setup!

    lineup = fixture.lineup_for(club)
    expected_slots = LineupTemplate.for(lineup.formation).map { |slot| slot.name.to_s }

    assert_equal expected_slots, lineup.starters.map(&:lineup_slot_key)
    assert(lineup.bench.all? { |lineup_athlete| lineup_athlete.lineup_slot_key.start_with?("sub_") })
  end

  test "builds a twenty player matchday squad and reserves" do
    fixture = fixtures(:one)
    club = fixture.home_club
    club.athlete_contracts.update_all(current: false)
    add_balanced_squad_depth(club)
    6.times { |index| add_depth_player(club, :central_midfielder, 100 + index) }

    fixture.ensure_match_setup!

    lineup = fixture.lineup_for(club)

    assert_equal 11, lineup.starters.count
    assert_equal 9, lineup.bench.count
    assert_equal 5, lineup.reserves.count
    assert(lineup.bench.all? { |lineup_athlete| lineup_athlete.lineup_slot_key.start_with?("sub_") })
    assert(lineup.reserves.all? { |lineup_athlete| lineup_athlete.lineup_slot_key.start_with?("res_") })
  end

  test "formation templates define eleven starter slots" do
    LineupTemplate::TEMPLATES.each_key do |formation|
      slots = LineupTemplate.for(formation)

      assert_equal 11, slots.length, "#{formation} should have eleven starters"
      assert_equal 1, slots.count { |slot| slot.position == :goalkeeper }, "#{formation} should have one goalkeeper"
    end
  end

  private

  def create_contracted_athlete(club, first_name, index, position, ability)
    athlete = create_athlete(club, first_name, "Depth #{index}", position, ability)

    club.athlete_contracts.create!(
      athlete:,
      start_date: Date.new(2026, 1, 1),
      wage: 100,
      status: :active,
      current: true
    )
  end

  def add_balanced_squad_depth(club)
    positions = %i[
      goalkeeper goalkeeper
      center_back center_back center_back center_back
      full_back full_back full_back full_back
      defensive_midfielder central_midfielder central_midfielder attacking_midfielder
      winger winger striker striker striker
    ]

    positions.each_with_index do |position, index|
      create_contracted_athlete(club, "Depth", index, position, 5)
    end
  end

  def create_athlete(club, first_name, last_name, position, ability)
    Athlete.create!(
      country: club.country,
      first_name:,
      last_name:,
      position:,
      preferred_foot: :right,
      current_ability: ability,
      potential_ability: ability,
      reputation: 1,
      morale: 50,
      condition: 100,
      status: :active,
      **Athlete::ATTRIBUTES.index_with { ability }
    )
  end
end
