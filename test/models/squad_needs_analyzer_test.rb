# frozen_string_literal: true

require "test_helper"

class SquadNeedsAnalyzerTest < ActiveSupport::TestCase
  test "reports missing positions against minimum squad shape" do
    club = clubs(:one)
    athlete_contracts(:one).update!(club:, current: true, status: :active)
    athletes(:one).update!(position: :goalkeeper)

    needs = SquadNeedsAnalyzer.call(club:)

    assert_equal 1, needs.fetch("goalkeeper")
    assert_equal 3, needs.fetch("center_back")
  end
end
