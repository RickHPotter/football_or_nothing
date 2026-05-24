# frozen_string_literal: true

require "test_helper"

module DataImport
  class ImportersTest < ActiveSupport::TestCase
    test "imports countries idempotently and tracks run" do
      rows = [
        { external_id: "br", name: "Brazil", code: "BRZ", reputation: 12 }
      ]

      assert_difference "Country.count", 1 do
        CountriesImporter.call(source: "fixture", rows:)
      end

      assert_no_difference "Country.count" do
        CountriesImporter.call(source: "fixture", rows:)
      end

      assert DataImportRun.last.completed?
      assert_equal 1, DataImportRun.last.records_processed
    end

    test "imports club athlete and contract relationships" do
      CountriesImporter.call(source: "fixture", rows: [
        { external_id: "cty", name: "Importia", code: "IMP", reputation: 7 }
      ])
      ClubsImporter.call(source: "fixture", rows: [
        { external_id: "club", country_external_id: "cty", name: "Importia FC", short_name: "IFC", reputation: 8 }
      ])
      AthletesImporter.call(source: "fixture", rows: [
        { external_id: "athlete", country_external_id: "cty", first_name: "Import", last_name: "Player", position: "striker", current_ability: 9, potential_ability: 12 }
      ])

      assert_difference "AthleteContract.count", 1 do
        ContractsImporter.call(source: "fixture", rows: [
          { external_id: "contract", athlete_external_id: "athlete", club_external_id: "club", start_date: Date.new(2026, 1, 1), wage: 100 }
        ])
      end

      athlete = Athlete.find_by!(external_source: "fixture", external_id: "athlete")
      club = Club.find_by!(external_source: "fixture", external_id: "club")

      assert_equal club, athlete.current_club
    end
  end
end
