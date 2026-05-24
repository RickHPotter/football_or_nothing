# frozen_string_literal: true

require "test_helper"

class ManagerJobEligibilityTest < ActiveSupport::TestCase
  test "uses reputation to decide eligible jobs" do
    manager = managers(:one)
    manager.update!(reputation: 2)
    club = clubs(:one)

    club.update!(reputation: 7)
    assert manager.eligible_for_club?(club)

    club.update!(reputation: 8)
    assert_not manager.eligible_for_club?(club)
  end
end
