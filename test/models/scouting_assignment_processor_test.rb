require "test_helper"

class ScoutingAssignmentProcessorTest < ActiveSupport::TestCase
  setup do
    @club = clubs(:one)
    @athlete = athletes(:two)
    @athlete.update!(
      country: countries(:two),
      position: :striker,
      current_ability: 9,
      potential_ability: 13,
      reputation: 1
    )
    athlete_contracts(:two).update!(club: clubs(:two), athlete: @athlete, current: true, status: :active)
  end

  test "creates reports for completed assignments" do
    assignment = @club.scouting_assignments.create!(
      country: countries(:two),
      position: :striker,
      focus: :first_team,
      starts_on: Date.new(2026, 1, 1),
      ends_on: Date.new(2026, 1, 15)
    )

    assert_difference "ScoutReport.count", 1 do
      reports = ScoutingAssignmentProcessor.call(club: @club, date: Date.new(2026, 1, 16))
      assert_equal [ @athlete ], reports.map(&:athlete)
    end

    assert assignment.reload.completed?
    assert_equal @club, ScoutReport.last.club
  end

  test "ignores active assignments before end date" do
    @club.scouting_assignments.create!(
      focus: :general,
      starts_on: Date.new(2026, 1, 1),
      ends_on: Date.new(2026, 1, 15)
    )

    assert_no_difference "ScoutReport.count" do
      ScoutingAssignmentProcessor.call(club: @club, date: Date.new(2026, 1, 14))
    end
  end
end
