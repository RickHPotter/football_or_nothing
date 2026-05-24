# frozen_string_literal: true

require "test_helper"

class AthleteAvailabilityTest < ActiveSupport::TestCase
  test "active athlete is available when not injured or suspended" do
    athlete = athletes(:one)
    athlete.update!(status: :active, injury_until: nil, suspended_until: nil)

    assert athlete.available_on?(Date.new(2026, 2, 1))
  end

  test "injured or suspended athlete is unavailable until date passes" do
    athlete = athletes(:one)
    athlete.update!(status: :active, injury_until: Date.new(2026, 2, 8), suspended_until: nil)

    assert_not athlete.available_on?(Date.new(2026, 2, 8))
    assert athlete.available_on?(Date.new(2026, 2, 9))

    athlete.update!(injury_until: nil, suspended_until: Date.new(2026, 2, 10))

    assert_not athlete.available_on?(Date.new(2026, 2, 10))
    assert athlete.available_on?(Date.new(2026, 2, 11))
  end
end
