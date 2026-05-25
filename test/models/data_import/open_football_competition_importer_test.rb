# frozen_string_literal: true

require "test_helper"

module DataImport
  class OpenFootballCompetitionImporterTest < ActiveSupport::TestCase
    def payload
      {
        name: "Premier League",
        season: "2023-24",
        matches: [
          {
            date: "2023-08-11",
            round: 1,
            team1: "Burnley FC",
            team2: "Manchester City FC",
            score: { ft: [ 0, 3 ] }
          },
          {
            date: "2023-08-12",
            round: 1,
            team1: "Arsenal FC",
            team2: "Nottingham Forest FC"
          }
        ]
      }
    end

    test "imports openfootball competition payload" do
      edition = nil

      assert_difference "Fixture.count", 2 do
        edition = OpenFootballCompetitionImporter.call(
          source: "openfootball:england",
          payload:,
          country_name: "England",
          country_code: "ENG"
        )
      end

      assert_equal "Premier League 2023", edition.name
      assert_equal 4, edition.clubs.count
      assert_equal Date.new(2023, 8, 11), edition.starts_on
      assert_equal Date.new(2023, 8, 12), edition.ends_on
      assert edition.fixtures.exists?(home_goals: 0, away_goals: 3, status: :completed)
      assert edition.fixtures.exists?(status: :scheduled)
      assert DataImportRun.last.completed?
    end

    test "is idempotent for the same payload" do
      OpenFootballCompetitionImporter.call(
        source: "openfootball:england",
        payload:,
        country_name: "England",
        country_code: "ENG"
      )

      assert_no_difference "Fixture.count" do
        OpenFootballCompetitionImporter.call(
          source: "openfootball:england",
          payload:,
          country_name: "England",
          country_code: "ENG"
        )
      end
    end
  end
end
