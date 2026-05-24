# frozen_string_literal: true

require "test_helper"

class MatchStrengthCalculatorTest < ActiveSupport::TestCase
  setup do
    @fixture = fixtures(:one)
    @club = @fixture.home_club
    @fixture.ensure_match_setup!
  end

  test "attacking mentality increases attack and lowers defense" do
    lineup = @fixture.lineup_for(@club)
    lineup.update!(mentality: :balanced)
    balanced = MatchStrengthCalculator.call(fixture: @fixture, club: @club)

    lineup.update!(mentality: :attacking)
    attacking = MatchStrengthCalculator.call(fixture: @fixture, club: @club)

    assert_operator attacking[:attack], :>, balanced[:attack]
    assert_operator attacking[:defense], :<, balanced[:defense]
  end

  test "red cards reduce team strength" do
    before_card = MatchStrengthCalculator.call(fixture: @fixture, club: @club)
    athlete = @fixture.lineup_for(@club).starters.first.athlete
    @fixture.match_events.create!(
      club: @club,
      athlete:,
      minute: 40,
      event_type: :red_card,
      description: "Dismissed."
    )

    after_card = MatchStrengthCalculator.call(fixture: @fixture, club: @club)

    assert_operator after_card[:attack], :<, before_card[:attack]
    assert_operator after_card[:defense], :<, before_card[:defense]
  end
end
