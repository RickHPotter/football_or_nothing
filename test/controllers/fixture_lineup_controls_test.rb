# frozen_string_literal: true

require "test_helper"

class FixtureLineupControlsTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
    @career = careers(:one)
    manager_contracts(:one).update!(current: true, status: :active, role: :head_coach, end_date: nil)
    @fixture = fixtures(:one)
  end

  test "updates managed club tactics" do
    add_balanced_squad_depth(@career.manager.current_club)
    get career_fixture_path(@career, @fixture)

    patch tactics_career_fixture_path(@career, @fixture), params: {
      lineup: {
        formation: "4-3-3",
        mentality: "attacking"
      }
    }

    assert_redirected_to career_fixture_path(@career, @fixture)
    lineup = @fixture.reload.lineup_for(@career.manager.current_club)
    assert_equal "4-3-3", lineup.formation
    assert lineup.attacking?
    assert_equal 11, lineup.starters.count
  end

  test "regenerates managed lineup before kickoff" do
    add_balanced_squad_depth(@career.manager.current_club)
    get career_fixture_path(@career, @fixture)
    lineup = @fixture.reload.lineup_for(@career.manager.current_club)
    original_lineup_athlete_ids = lineup.lineup_athletes.pluck(:id)

    post regenerate_lineup_career_fixture_path(@career, @fixture)

    assert_redirected_to career_fixture_path(@career, @fixture)
    assert_equal "Lineup regenerated.", flash[:notice]
    assert_equal 11, lineup.reload.starters.count
    assert_not_equal original_lineup_athlete_ids.sort, lineup.lineup_athletes.pluck(:id).sort
  end

  test "does not regenerate managed lineup after kickoff" do
    post start_career_fixture_path(@career, @fixture)

    post regenerate_lineup_career_fixture_path(@career, @fixture)

    assert_redirected_to career_fixture_path(@career, @fixture)
    assert_equal "Lineups can only be regenerated before kickoff.", flash[:alert]
  end

  test "records substitution for managed club" do
    add_balanced_squad_depth(@career.manager.current_club)
    get career_fixture_path(@career, @fixture)

    lineup = @fixture.reload.lineup_for(@career.manager.current_club)
    starter = lineup.starters.first
    substitute = lineup.bench.first

    post substitute_career_fixture_path(@career, @fixture), params: {
      off_lineup_athlete_id: starter.id,
      on_lineup_athlete_id: substitute.id
    }

    assert_redirected_to career_fixture_path(@career, @fixture)
    assert_not starter.reload.starter?
    assert substitute.reload.starter?
    assert_equal 1, @fixture.match_state.reload.home_substitutions
  end

  test "does not allow substituted off player to re-enter" do
    add_balanced_squad_depth(@career.manager.current_club)
    get career_fixture_path(@career, @fixture)

    lineup = @fixture.reload.lineup_for(@career.manager.current_club)
    starter = lineup.starters.first
    substitute = lineup.bench.first

    post substitute_career_fixture_path(@career, @fixture), params: {
      off_lineup_athlete_id: starter.id,
      on_lineup_athlete_id: substitute.id
    }

    next_starter = lineup.reload.starters.where.not(id: substitute.id).first
    post substitute_career_fixture_path(@career, @fixture), params: {
      off_lineup_athlete_id: next_starter.id,
      on_lineup_athlete_id: starter.id
    }

    assert_redirected_to career_fixture_path(@career, @fixture)
    assert_equal "Choose one active starter and one unused substitute.", flash[:alert]
    assert_not starter.reload.starter?
  end

  test "allows substituted on player to be substituted off" do
    add_balanced_squad_depth(@career.manager.current_club)
    get career_fixture_path(@career, @fixture)

    lineup = @fixture.reload.lineup_for(@career.manager.current_club)
    starter = lineup.starters.first
    substitute = lineup.bench.first

    post substitute_career_fixture_path(@career, @fixture), params: {
      off_lineup_athlete_id: starter.id,
      on_lineup_athlete_id: substitute.id
    }

    next_substitute = lineup.reload.bench.where(substituted_on_minute: nil, substituted_off_minute: nil).first
    post substitute_career_fixture_path(@career, @fixture), params: {
      off_lineup_athlete_id: substitute.id,
      on_lineup_athlete_id: next_substitute.id
    }

    assert_redirected_to career_fixture_path(@career, @fixture)
    assert_not substitute.reload.starter?
    assert next_substitute.reload.starter?
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
      add_depth_player(club, position, index)
    end
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
