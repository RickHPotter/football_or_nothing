# frozen_string_literal: true

require "test_helper"

class CareerTest < ActiveSupport::TestCase
  test "next fixture returns next scheduled fixture for current club" do
    manager_contracts(:one).update!(current: true, status: :active, role: :head_coach, end_date: nil)
    careers(:one).update!(current_date: "2026-01-01")

    assert_equal fixtures(:one), careers(:one).next_fixture
  end

  test "next fixture ignores completed fixtures" do
    manager_contracts(:one).update!(current: true, status: :active, role: :head_coach, end_date: nil)
    careers(:one).update!(current_date: "2026-01-01")
    fixtures(:one).completed!

    assert_equal fixtures(:two), careers(:one).next_fixture
  end
end
