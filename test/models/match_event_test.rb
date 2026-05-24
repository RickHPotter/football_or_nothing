# frozen_string_literal: true

require "test_helper"

class MatchEventTest < ActiveSupport::TestCase
  test "supports detailed event types" do
    event = match_events(:one)

    event.major_chance!
    assert event.major_chance?

    event.yellow_card!
    assert event.yellow_card?

    event.red_card!
    assert event.red_card?

    event.injury!
    assert event.injury?

    event.substitution!
    assert event.substitution?
  end
end
