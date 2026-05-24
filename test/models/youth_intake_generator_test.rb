require "test_helper"

class YouthIntakeGeneratorTest < ActiveSupport::TestCase
  test "generates prospects once per club season" do
    club = clubs(:one)
    club.update!(academy_quality: 10, reputation: 8)

    assert_difference "Athlete.count", 5 do
      assert_difference "NewsItem.youth.count", 1 do
        YouthIntakeGenerator.call(club:, season_year: 2026, generated_on: Date.new(2026, 1, 1))
      end
    end

    assert_no_difference "Athlete.count" do
      YouthIntakeGenerator.call(club:, season_year: 2026, generated_on: Date.new(2026, 1, 1))
    end

    intake = club.youth_intakes.find_by!(season_year: 2026)
    assert_equal 5, intake.athletes.count
    assert intake.athletes.all?(&:youth_academy_player?)
  end
end
