# frozen_string_literal: true

require "test_helper"

class AiSubstitutionPlannerTest < ActiveSupport::TestCase
  setup do
    @fixture = fixtures(:one)
    @club = @fixture.away_club
    @club.athlete_contracts.update_all(current: false)
    add_balanced_squad_depth(@club)
    @fixture.ensure_match_setup!
  end

  test "does not make early substitutions" do
    assert_no_difference [ "LineupAthlete.where(starter: true).count", "MatchEvent.substitution.count" ] do
      AiSubstitutionPlanner.call(fixture: @fixture, club: @club, minute: 45)
    end
  end

  test "substitutes an unused bench player after threshold" do
    lineup = @fixture.lineup_for(@club)
    original_starter_ids = lineup.starters.pluck(:id)

    AiSubstitutionPlanner.call(fixture: @fixture, club: @club, minute: 60)

    lineup.reload
    assert_equal 11, lineup.starters.count
    assert_equal 1, @fixture.match_state.reload.away_substitutions
    assert_not_equal original_starter_ids.sort, lineup.starters.pluck(:id).sort
    assert_equal 1, @fixture.match_events.substitution.where(club: @club, minute: 60).count
  end

  test "does not exceed five substitutions" do
    @fixture.match_state.update!(away_substitutions: 5)

    assert_no_difference "MatchEvent.substitution.count" do
      AiSubstitutionPlanner.call(fixture: @fixture, club: @club, minute: 75)
    end
  end

  private

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
      current_ability: 5 + (index % 5),
      potential_ability: 10,
      reputation: 1,
      morale: 50,
      condition: 100 - index,
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
