# frozen_string_literal: true

require "test_helper"

class LiveMatchEventApplierTest < ActiveSupport::TestCase
  test "applies due planned events once" do
    fixture = fixtures(:one)
    fixture.match_events.destroy_all
    session = MatchdaySessionStarter.call(career: careers(:one), fixture:)
    MatchdayEventPlanner.call(session:)
    first_event = session.matchday_events.order(:minute).first
    due_count = session.matchday_events.due(first_event.minute).count

    assert_difference "MatchEvent.count", due_count do
      LiveMatchEventApplier.call(session:, minute: first_event.minute)
    end

    assert session.matchday_events.due(first_event.minute).empty?
    assert_no_difference "MatchEvent.count" do
      LiveMatchEventApplier.call(session:, minute: first_event.minute)
    end
  end

  test "does not apply future events" do
    fixture = fixtures(:one)
    fixture.match_events.destroy_all
    session = MatchdaySessionStarter.call(career: careers(:one), fixture:)
    MatchdayEventPlanner.call(session:)
    first_event = session.matchday_events.order(:minute).first

    assert_no_difference "MatchEvent.count" do
      LiveMatchEventApplier.call(session:, minute: first_event.minute - 1)
    end
  end

  test "applies ai substitutions only for non managed clubs" do
    career = careers(:one)
    fixture = fixtures(:one)
    manager_contracts(:one).update!(current: true, status: :active, role: :head_coach, end_date: nil)
    managed_club = career.manager.current_club
    opponent = fixture.home_club == managed_club ? fixture.away_club : fixture.home_club
    opponent.athlete_contracts.update_all(current: false)
    add_balanced_squad_depth(opponent)
    fixture.ensure_match_setup!
    fixture.match_events.destroy_all
    fixture.match_state.update!(home_substitutions: 0, away_substitutions: 0)
    session = MatchdaySessionStarter.call(career:, fixture:)

    LiveMatchEventApplier.call(session:, minute: 60)

    fixture.reload
    assert_equal 0, fixture.club_substitution_count(managed_club)
    assert_equal 1, fixture.club_substitution_count(opponent)
    assert_equal 1, fixture.match_events.substitution.where(club: opponent, minute: 60).count
    assert_empty fixture.match_events.substitution.where(club: managed_club)
  end
end
