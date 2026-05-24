# frozen_string_literal: true

require "test_helper"

class StaffHiringProcessorTest < ActiveSupport::TestCase
  setup do
    @club = clubs(:one)
    @staff = StaffMember.create!(
      country: countries(:one),
      first_name: "Rui",
      last_name: "Mendes",
      role: :coach,
      reputation: 8,
      coaching: 12,
      fitness: 8,
      scouting: 6,
      judging_ability: 7,
      judging_potential: 7,
      physiotherapy: 5,
      discipline: 9,
      motivation: 10
    )
    @club.club_finance.update!(wage_budget: 10_000)
  end

  test "hires free staff member" do
    contract = StaffHiringProcessor.call(
      staff_member: @staff,
      club: @club,
      start_date: Date.new(2026, 1, 1),
      wage: 500
    )

    assert contract.active?
    assert contract.current?
    assert_equal @club, @staff.reload.current_club
  end

  test "rejects unaffordable staff wage" do
    @club.club_finance.update!(wage_budget: 100)

    assert_no_difference "StaffContract.count" do
      assert_raises ActiveRecord::RecordInvalid do
        StaffHiringProcessor.call(
          staff_member: @staff,
          club: @club,
          start_date: Date.new(2026, 1, 1),
          wage: 500
        )
      end
    end
  end
end
