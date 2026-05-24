require "test_helper"

class TrainingPlansControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
    @career = careers(:one)
    manager_contracts(:one).update!(current: true, status: :active, role: :head_coach, end_date: nil)
  end

  test "updates current club training plan" do
    assert_difference "TrainingPlan.count", 1 do
      patch career_training_plan_path(@career), params: {
        training_plan: {
          focus: "fitness",
          intensity: "high"
        }
      }
    end

    assert_redirected_to career_club_path(@career)
    plan = clubs(:one).reload.training_plan
    assert plan.fitness?
    assert plan.high?
  end
end
