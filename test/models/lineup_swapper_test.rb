# frozen_string_literal: true

require "test_helper"

class LineupSwapperTest < ActiveSupport::TestCase
  test "swaps two athletes between lineup slots" do
    fixture = fixtures(:one)
    club = fixture.home_club
    club.athlete_contracts.update_all(current: false)
    add_balanced_squad_depth(club)
    fixture.ensure_match_setup!
    lineup = fixture.lineup_for(club)
    starter = lineup.starters.find_by!(lineup_slot_key: "rb")
    substitute = lineup.bench.first
    starter_attributes = swappable_attributes(starter)
    substitute_attributes = swappable_attributes(substitute)

    LineupSwapper.call(
      lineup:,
      from_lineup_athlete_id: starter.id,
      to_lineup_athlete_id: substitute.id
    )

    assert_equal substitute_attributes, swappable_attributes(starter.reload)
    assert_equal starter_attributes, swappable_attributes(substitute.reload)
  end

  test "ignores swapping an athlete with itself" do
    fixture = fixtures(:one)
    fixture.ensure_match_setup!
    lineup = fixture.lineup_for(fixture.home_club)
    lineup_athlete = lineup.lineup_athletes.first
    original_attributes = swappable_attributes(lineup_athlete)

    LineupSwapper.call(
      lineup:,
      from_lineup_athlete_id: lineup_athlete.id,
      to_lineup_athlete_id: lineup_athlete.id
    )

    assert_equal original_attributes, swappable_attributes(lineup_athlete.reload)
  end

  private

  def swappable_attributes(lineup_athlete)
    lineup_athlete.attributes.slice(*LineupSwapper::SWAPPABLE_ATTRIBUTES)
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
      create_contracted_athlete(club, position, index)
    end
  end

  def create_contracted_athlete(club, position, index)
    athlete = Athlete.create!(
      country: club.country,
      first_name: "Depth",
      last_name: "Player #{index}",
      position:,
      preferred_foot: :right,
      current_ability: 5,
      potential_ability: 5,
      reputation: 1,
      morale: 50,
      condition: 100,
      status: :active,
      **Athlete::ATTRIBUTES.index_with { 5 }
    )
    club.athlete_contracts.create!(
      athlete:,
      start_date: Date.new(2026, 1, 1),
      wage: 100,
      status: :active,
      current: true
    )
  end
end
