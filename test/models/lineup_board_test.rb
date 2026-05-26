# frozen_string_literal: true

require "test_helper"

class LineupBoardTest < ActiveSupport::TestCase
  test "groups starters into formation rows" do
    fixture = fixtures(:one)
    club = fixture.home_club
    club.athlete_contracts.update_all(current: false)
    add_balanced_squad_depth(club)
    fixture.ensure_match_setup!

    lineup = fixture.lineup_for(club)
    rows = LineupBoard.rows_for(lineup)

    assert_equal([ %w[lst rst], %w[lm lcm rcm rm], %w[lb lcb rcb rb], %w[gk] ], rows.map { |row| row.map(&:lineup_slot_key) })
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
