# frozen_string_literal: true

require "test_helper"

class FixtureLiveLineupSwapTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
    @career = careers(:one)
    manager_contracts(:one).update!(current: true, status: :active, role: :head_coach, end_date: nil)
    @fixture = fixtures(:one)
  end

  test "swaps active starters during paused matchday" do
    lineup = managed_lineup
    right_back = lineup.starters.find_by!(lineup_slot_key: "rb")
    left_back = lineup.starters.find_by!(lineup_slot_key: "lb")

    patch swap_lineup_athletes_career_fixture_path(@career, @fixture), params: {
      from_lineup_athlete_id: right_back.id,
      to_lineup_athlete_id: left_back.id
    }

    assert_redirected_to career_fixture_path(@career, @fixture, details: true)
    assert_nil flash[:notice]
    assert_equal "lb", right_back.reload.lineup_slot_key
    assert_equal "rb", left_back.reload.lineup_slot_key
    assert right_back.starter?
    assert left_back.starter?
    assert_equal 0, @fixture.match_state.reload.home_substitutions
  end

  test "does not use live swap endpoint for bench substitutions" do
    lineup = managed_lineup
    starter = lineup.starters.first
    substitute = lineup.bench.first

    patch swap_lineup_athletes_career_fixture_path(@career, @fixture), params: {
      from_lineup_athlete_id: starter.id,
      to_lineup_athlete_id: substitute.id
    }

    assert_redirected_to career_fixture_path(@career, @fixture, details: true)
    assert_equal "Choose two active starters from your lineup.", flash[:alert]
    assert starter.reload.starter?
    assert_not substitute.reload.starter?
  end

  private

  def managed_lineup
    add_balanced_squad_depth(@career.manager.current_club)
    get career_fixture_path(@career, @fixture)
    pause_matchday
    @fixture.reload.lineup_for(@career.manager.current_club)
  end

  def pause_matchday
    session = MatchdaySessionStarter.call(career: @career, fixture: @fixture)
    MatchdayClock.start(session, now: Time.current)
    MatchdayClock.pause(session, now: Time.current + 2.seconds)
  end
end
