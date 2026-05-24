require "test_helper"

class TrainingApplierTest < ActiveSupport::TestCase
  setup do
    @club = clubs(:one)
    @manager = managers(:one)
    @athlete = athletes(:one)
    @athlete.update!(
      birthdate: Date.new(2007, 1, 1),
      condition: 90,
      current_ability: 8,
      potential_ability: 14,
      finishing: 8,
      passing: 8,
      composure: 8
    )
    athlete_contracts(:one).update!(club: @club, athlete: @athlete, current: true, status: :active)
  end

  test "applies active training plan to current squad" do
    TrainingPlan.create!(
      club: @club,
      manager: @manager,
      focus: :attacking,
      intensity: :high,
      active_from: Date.new(2026, 1, 1)
    )

    assert_difference "TrainingResult.count", 1 do
      TrainingApplier.call(
        club: @club,
        manager: @manager,
        from_date: Date.new(2026, 1, 1),
        to_date: Date.new(2026, 1, 15)
      )
    end

    assert_equal 80, @athlete.reload.condition
    assert_equal @club, TrainingResult.last.club
  end

  test "creates default balanced plan when none exists" do
    assert_difference "TrainingPlan.count", 1 do
      TrainingApplier.call(
        club: @club,
        manager: @manager,
        from_date: Date.new(2026, 1, 1),
        to_date: Date.new(2026, 1, 8)
      )
    end

    assert @club.reload.training_plan.balanced?
  end
end
