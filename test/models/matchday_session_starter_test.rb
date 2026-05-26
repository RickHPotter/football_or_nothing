# frozen_string_literal: true

require "test_helper"

class MatchdaySessionStarterTest < ActiveSupport::TestCase
  test "creates a session from a selected fixture" do
    fixture = fixtures(:one)

    session = MatchdaySessionStarter.call(career: careers(:one), fixture:)

    assert_predicate session, :persisted?
    assert_equal careers(:one), session.career
    assert_equal fixture.tournament_edition, session.tournament_edition
    assert_equal fixture.scheduled_on, session.scheduled_on
    assert_equal fixture.round, session.round
    assert_equal fixture, session.focused_fixture
    assert session.not_started?
    assert session.pre_match?
  end

  test "reuses the existing session for the same matchday" do
    fixture = fixtures(:one)
    original = MatchdaySessionStarter.call(career: careers(:one), fixture:)

    assert_no_difference "MatchdaySession.count" do
      assert_equal original, MatchdaySessionStarter.call(career: careers(:one), fixture:)
    end
  end
end
