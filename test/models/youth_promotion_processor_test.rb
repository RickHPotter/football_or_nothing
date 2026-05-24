# frozen_string_literal: true

require "test_helper"

class YouthPromotionProcessorTest < ActiveSupport::TestCase
  setup do
    @club = clubs(:one)
    @club.club_finance.update!(wage_budget: 10_000)
    @intake = YouthIntakeGenerator.call(club: @club, season_year: 2026, generated_on: Date.new(2026, 1, 1), count: 1)
    @athlete = @intake.athletes.first
  end

  test "promotes academy prospect to senior squad" do
    contract = nil
    assert_difference "NewsItem.youth.count", 1 do
      contract = YouthPromotionProcessor.call(
        athlete: @athlete,
        club: @club,
        promotion_date: Date.new(2026, 1, 2),
        wage: 100
      )
    end

    assert contract.current?
    assert @athlete.reload.academy_graduate?
    assert_not @athlete.youth_academy_player?
    assert_equal @club, @athlete.current_club
  end

  test "rejects prospect from another academy" do
    assert_raises ActiveRecord::RecordInvalid do
      YouthPromotionProcessor.call(
        athlete: @athlete,
        club: clubs(:two),
        promotion_date: Date.new(2026, 1, 2),
        wage: 100
      )
    end
  end
end
