# frozen_string_literal: true

require "test_helper"

class MatchdayStandingSnapshotTest < ActiveSupport::TestCase
  test "movement is positive when club gains positions" do
    snapshot = MatchdayStandingSnapshot.new(position_before: 4, position_after: 2)

    assert_equal 2, snapshot.movement
  end
end
