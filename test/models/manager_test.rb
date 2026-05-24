# frozen_string_literal: true

require "test_helper"

class ManagerTest < ActiveSupport::TestCase
  test "international jobs require high reputation" do
    club = clubs(:one)
    club.update!(international: true, reputation: 5)

    assert_not managers(:one).eligible_for_club?(club)

    managers(:one).update!(reputation: 12)
    assert managers(:one).eligible_for_club?(club)
  end
end
