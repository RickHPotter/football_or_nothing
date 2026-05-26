# frozen_string_literal: true

require "test_helper"

class MatchStrengthCalculatorTest < ActiveSupport::TestCase
  setup do
    @fixture = fixtures(:one)
    @club = @fixture.home_club
    @fixture.ensure_match_setup!
  end

  test "attacking mentality increases attack and lowers defense" do
    lineup = @fixture.lineup_for(@club)
    lineup.update!(mentality: :balanced)
    balanced = MatchStrengthCalculator.call(fixture: @fixture, club: @club)

    lineup.update!(mentality: :attacking)
    attacking = MatchStrengthCalculator.call(fixture: @fixture, club: @club)

    assert_operator attacking[:attack], :>, balanced[:attack]
    assert_operator attacking[:defense], :<, balanced[:defense]
  end

  test "red cards reduce team strength" do
    before_card = MatchStrengthCalculator.call(fixture: @fixture, club: @club)
    athlete = @fixture.lineup_for(@club).starters.first.athlete
    @fixture.match_events.create!(
      club: @club,
      athlete:,
      minute: 40,
      event_type: :red_card,
      description: "Dismissed."
    )

    after_card = MatchStrengthCalculator.call(fixture: @fixture, club: @club)

    assert_operator after_card[:attack], :<, before_card[:attack]
    assert_operator after_card[:defense], :<, before_card[:defense]
  end

  test "players outside natural positions reduce team strength" do
    rebuild_balanced_lineup
    lineup = @fixture.lineup_for(@club)
    natural = MatchStrengthCalculator.call(fixture: @fixture, club: @club)

    LineupSwapper.call(
      lineup:,
      from_lineup_athlete_id: lineup.starters.find_by!(lineup_slot_key: "gk").id,
      to_lineup_athlete_id: lineup.starters.find_by!(lineup_slot_key: "rst").id
    )
    awkward = MatchStrengthCalculator.call(fixture: @fixture, club: @club)

    assert_operator awkward[:attack], :<, natural[:attack]
    assert_operator awkward[:defense], :<, natural[:defense]
    assert_operator awkward[:control], :<, natural[:control]
  end

  test "tactical roles influence team strength" do
    rebuild_balanced_lineup
    lineup = @fixture.lineup_for(@club)
    balanced = MatchStrengthCalculator.call(fixture: @fixture, club: @club)

    lineup.starters.update_all(tactical_role: LineupAthlete.tactical_roles[:attack])
    attacking_roles = MatchStrengthCalculator.call(fixture: @fixture, club: @club)

    lineup.starters.update_all(tactical_role: LineupAthlete.tactical_roles[:defend])
    defending_roles = MatchStrengthCalculator.call(fixture: @fixture, club: @club)

    assert_operator attacking_roles[:attack], :>, balanced[:attack]
    assert_operator attacking_roles[:defense], :<, balanced[:defense]
    assert_operator defending_roles[:defense], :>, balanced[:defense]
    assert_operator defending_roles[:attack], :<, balanced[:attack]
  end

  private

  def rebuild_balanced_lineup
    @fixture.lineups.destroy_all
    @club.athlete_contracts.update_all(current: false)
    add_balanced_squad_depth
    @fixture.ensure_match_setup!
  end

  def add_balanced_squad_depth
    positions = %i[
      goalkeeper goalkeeper
      center_back center_back center_back center_back
      full_back full_back full_back full_back
      defensive_midfielder central_midfielder central_midfielder attacking_midfielder
      winger winger striker striker striker
    ]

    positions.each_with_index do |position, index|
      create_contracted_athlete(position, index)
    end
  end

  def create_contracted_athlete(position, index)
    athlete = Athlete.create!(
      country: @club.country,
      first_name: "Depth",
      last_name: "Player #{index}",
      position:,
      preferred_foot: :right,
      current_ability: 10,
      potential_ability: 10,
      reputation: 1,
      morale: 50,
      condition: 100,
      status: :active,
      **Athlete::ATTRIBUTES.index_with { 10 }
    )
    @club.athlete_contracts.create!(
      athlete:,
      start_date: Date.new(2026, 1, 1),
      wage: 100,
      status: :active,
      current: true
    )
  end
end
