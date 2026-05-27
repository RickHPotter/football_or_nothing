# frozen_string_literal: true

module LineupDepthTestHelper
  def add_balanced_squad_depth(club)
    %i[
      goalkeeper goalkeeper
      center_back center_back center_back center_back
      full_back full_back full_back full_back
      defensive_midfielder central_midfielder central_midfielder attacking_midfielder
      winger winger striker striker striker
    ].each_with_index { |position, index| add_depth_player(club, position, index) }
  end

  def add_depth_player(club, position, index)
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
