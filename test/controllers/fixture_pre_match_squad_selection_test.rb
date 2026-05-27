# frozen_string_literal: true

require "test_helper"

class FixturePreMatchSquadSelectionTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
    @career = careers(:one)
    manager_contracts(:one).update!(current: true, status: :active, role: :head_coach, end_date: nil)
    @fixture = fixtures(:one)
  end

  test "scheduled match exposes bench and non participating substitutes" do
    create_deep_managed_squad

    get career_fixture_path(@career, @fixture)

    assert_response :success
    assert_select "[data-controller='lineup-substitution']", 1
    assert_select ".lineup-action-form", 1
    assert_select "h3", "Bench"
    assert_select "h3", "Substitutes"
    assert_select ".bench-player-token[data-lineup-token-kind='substitute']", 9
    assert_select ".bench-player-token[data-lineup-token-kind='reserve']", minimum: 1
    assert_select ".bench-player-token[data-action*='drop->lineup-substitution#dropOnToken']", minimum: 10
  end

  test "scheduled match can swap a non participant into the starting eleven" do
    create_deep_managed_squad
    get career_fixture_path(@career, @fixture)
    lineup = @fixture.reload.lineup_for(@career.manager.current_club)
    starter = lineup.starters.find_by!(lineup_slot_key: "rb")
    reserve = lineup.reserves.first

    patch swap_lineup_athletes_career_fixture_path(@career, @fixture), params: {
      from_lineup_athlete_id: starter.id,
      to_lineup_athlete_id: reserve.id
    }

    assert_redirected_to career_fixture_path(@career, @fixture)
    assert_nil flash[:notice]
    assert_not starter.reload.starter?
    assert reserve.reload.starter?
    assert_equal "rb", reserve.lineup_slot_key
    assert_not_includes LineupBuilder::BENCH_SLOT_RANGE, reserve.lineup_slot
  end

  private

  def create_deep_managed_squad
    club = @career.manager.current_club
    club.athlete_contracts.update_all(current: false)
    add_balanced_squad_depth(club)
    8.times { |index| add_depth_player(club, :central_midfielder, 100 + index) }
  end
end
