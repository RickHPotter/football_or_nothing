require "test_helper"

class YouthIntakesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
    @career = careers(:one)
    manager_contracts(:one).update!(current: true, status: :active, role: :head_coach, end_date: nil)
    clubs(:one).club_finance.update!(wage_budget: 10_000)
  end

  test "shows youth academy screen" do
    get career_youth_intakes_path(@career)

    assert_response :success
    assert_select "h1", "Youth Academy"
  end

  test "generates youth intake" do
    assert_difference "YouthIntake.count", 1 do
      post career_youth_intakes_path(@career)
    end

    assert_redirected_to career_youth_intakes_path(@career)
    assert_equal 5, YouthIntake.last.athletes.count
  end

  test "promotes youth prospect" do
    intake = YouthIntakeGenerator.call(club: clubs(:one), season_year: 2026, generated_on: Date.new(2026, 1, 1), count: 1)
    athlete = intake.athletes.first

    assert_difference "AthleteContract.count", 1 do
      post promote_career_youth_intakes_path(@career), params: { athlete_id: athlete.id, wage: 100 }
    end

    assert_redirected_to career_youth_intakes_path(@career)
    assert athlete.reload.academy_graduate?
  end
end
