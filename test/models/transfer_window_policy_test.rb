require "test_helper"

class TransferWindowPolicyTest < ActiveSupport::TestCase
  test "opens during preseason and postseason windows" do
    club = clubs(:one)

    assert TransferWindowPolicy.open?(club:, date: Date.new(2026, 1, 15))
    assert TransferWindowPolicy.open?(club:, date: Date.new(2026, 5, 22))
  end

  test "closes outside known windows" do
    assert_not TransferWindowPolicy.open?(club: clubs(:one), date: Date.new(2026, 7, 1))
  end
end
