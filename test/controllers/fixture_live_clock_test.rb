# frozen_string_literal: true

require "test_helper"

class FixtureLiveClockTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
    @career = careers(:one)
    manager_contracts(:one).update!(current: true, status: :active, role: :head_coach, end_date: nil)
    @fixture = fixtures(:one)
    @opponent = @fixture.away_club
    @opponent.athlete_contracts.update_all(current: false)
    add_balanced_squad_depth(@opponent)
  end

  test "advancing live clock triggers opponent ai substitutions after sixty minutes" do
    post start_career_fixture_path(@career, @fixture)

    4.times { post advance_clock_career_fixture_path(@career, @fixture) }

    assert_redirected_to career_fixture_path(@career, @fixture)
    assert_equal 60, @fixture.match_state.reload.minute
    assert_equal 1, @fixture.match_state.away_substitutions
    assert_equal 1, @fixture.match_events.substitution.where(club: @opponent, minute: 60).count
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
