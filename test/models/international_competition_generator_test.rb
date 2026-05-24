# frozen_string_literal: true

require "test_helper"

class InternationalCompetitionGeneratorTest < ActiveSupport::TestCase
  test "creates international tournament with national teams and fixtures" do
    edition = InternationalCompetitionGenerator.call(
      countries: [ countries(:one), countries(:two) ],
      season_year: 2027,
      starts_on: Date.new(2027, 6, 1),
      ends_on: Date.new(2027, 6, 30)
    )

    assert edition.tournament.international?
    assert edition.clubs.all?(&:international?)
    assert edition.fixtures.any?
    assert edition.clubs.all? { |club| club.current_athletes.count >= 18 }
  end

  test "is idempotent for the same season" do
    first = InternationalCompetitionGenerator.call(
      countries: [ countries(:one), countries(:two) ],
      season_year: 2027,
      starts_on: Date.new(2027, 6, 1),
      ends_on: Date.new(2027, 6, 30)
    )

    assert_no_difference "TournamentEdition.count" do
      assert_equal first, InternationalCompetitionGenerator.call(
        countries: [ countries(:one), countries(:two) ],
        season_year: 2027,
        starts_on: Date.new(2027, 6, 1),
        ends_on: Date.new(2027, 6, 30)
      )
    end
  end
end
