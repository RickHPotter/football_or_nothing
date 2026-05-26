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
end
