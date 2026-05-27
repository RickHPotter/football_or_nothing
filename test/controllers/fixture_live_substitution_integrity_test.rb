# frozen_string_literal: true

require "test_helper"

class FixtureLiveSubstitutionIntegrityTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
    @career = careers(:one)
    manager_contracts(:one).update!(current: true, status: :active, role: :head_coach, end_date: nil)
    @fixture = fixtures(:one)
  end

  test "manual substitution preserves visible formation slot and retargets future events" do
    add_balanced_squad_depth(@career.manager.current_club)
    get career_fixture_path(@career, @fixture)
    pause_matchday

    lineup = @fixture.reload.lineup_for(@career.manager.current_club)
    starter = lineup.starters.first
    substitute = lineup.bench.first
    starter_slot_key = starter.lineup_slot_key
    planned_event = planned_goal_for(starter)

    post substitute_career_fixture_path(@career, @fixture), params: {
      off_lineup_athlete_id: starter.id,
      on_lineup_athlete_id: substitute.id
    }

    assert_redirected_to career_fixture_path(@career, @fixture, details: true)
    assert_not starter.reload.starter?
    assert substitute.reload.starter?
    assert_equal starter_slot_key, substitute.lineup_slot_key
    assert_equal 11, LineupBoard.rows_for(lineup.reload).flatten.count
    assert_equal substitute.athlete, planned_event.reload.athlete
    assert_includes planned_event.description, "#{substitute.athlete.first_name} #{substitute.athlete.last_name}"
  end

  private

  def pause_matchday
    session = MatchdaySessionStarter.call(career: @career, fixture: @fixture)
    MatchdayClock.start(session, now: Time.current)
    MatchdayClock.pause(session, now: Time.current + 2.seconds)
  end

  def planned_goal_for(lineup_athlete)
    matchday_session.matchday_events.create!(
      fixture: @fixture,
      club: @career.manager.current_club,
      athlete: lineup_athlete.athlete,
      minute: 80,
      event_type: :goal,
      description: "#{lineup_athlete.athlete.first_name} #{lineup_athlete.athlete.last_name} scored for #{@career.manager.current_club.name}."
    )
  end

  def matchday_session
    MatchdaySession.find_by!(
      career: @career,
      tournament_edition: @fixture.tournament_edition,
      scheduled_on: @fixture.scheduled_on,
      round: @fixture.round
    )
  end
end
