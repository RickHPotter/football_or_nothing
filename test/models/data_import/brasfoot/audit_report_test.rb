# frozen_string_literal: true

require "test_helper"

module DataImport
  module Brasfoot
    class AuditReportTest < ActiveSupport::TestCase
      test "reports imported brasfoot counts and data quality issues" do
        source = "brasfoot_audit_test"
        country = Country.create!(
          name: "Brasfoot Pack Audit",
          code: "BFA",
          reputation: 5,
          status: :active,
          external_source: source,
          external_id: "BFA"
        )
        fallback_country = Country.create!(
          name: PackImporter::DEFAULT_COUNTRY_NAME,
          code: PackImporter::DEFAULT_COUNTRY_CODE,
          reputation: 5,
          status: :active,
          external_source: source,
          external_id: PackImporter::DEFAULT_COUNTRY_CODE
        )
        complete_club = create_imported_club(country, source, "complete")
        complete_club.stadiums.create!(
          country:,
          name: "Complete Ground",
          city: "Audit City",
          capacity: 10_000,
          pitch_quality: 10,
          ownership: :club_owned
        )
        complete_club.crest.attach(io: StringIO.new("crest"), filename: "crest.png", content_type: "image/png")
        create_current_contract(create_imported_athlete(country, source, "contracted"), complete_club, source)

        fallback_club = create_imported_club(fallback_country, source, "fallback")
        create_imported_athlete(country, source, "free")

        tournament = Tournament.create!(
          country:,
          name: "Audit League",
          short_name: "AUD",
          scope: :domestic,
          format: :league,
          status: :active
        )
        TournamentEdition.create!(
          tournament:,
          season_year: 2026,
          name: "Audit League 2026",
          starts_on: Date.new(2026, 1, 1),
          ends_on: Date.new(2026, 5, 1),
          status: :scheduled
        )

        report = AuditReport.call(source:, limit: 10)

        assert_equal 2, report.summary.fetch(:clubs)
        assert_equal 2, report.summary.fetch(:athletes)
        assert_equal 1, report.summary.fetch(:contracts)
        assert_equal 1, report.summary.fetch(:club_assets)
        assert_equal 1, report.summary.fetch(:fallback_country_clubs)
        assert_equal([ "Fallback FC" ], report.issues.fetch(:fallback_country_clubs).map { |issue| issue.fetch(:club) })
        assert_equal([ "Fallback FC" ], report.issues.fetch(:clubs_without_stadiums).map { |issue| issue.fetch(:club) })
        assert_equal([ "Fallback FC" ], report.issues.fetch(:clubs_without_crests).map { |issue| issue.fetch(:club) })
        assert_equal([ "Free Player" ], report.issues.fetch(:athletes_without_current_contracts).map { |issue| issue.fetch(:athlete) })
        assert_equal([ "Audit League 2026" ], report.issues.fetch(:editions_without_clubs).map { |issue| issue.fetch(:edition) })
        assert_includes report.to_text, "[brasfoot:audit] source=#{source}"
        assert_includes report.to_text, "Fallback country clubs: 1"

        fallback_club.destroy!
      end

      private

      def create_imported_club(country, source, external_id)
        Club.create!(
          country:,
          name: "#{external_id.titleize} FC",
          short_name: external_id.first(12).upcase,
          reputation: 5,
          academy_quality: 8,
          status: :active,
          external_source: source,
          external_id:
        )
      end

      def create_imported_athlete(country, source, external_id)
        Athlete.create!(
          country:,
          first_name: external_id.titleize,
          last_name: "Player",
          birthdate: Date.new(2000, 1, 1),
          position: :striker,
          preferred_foot: :right,
          current_ability: 10,
          potential_ability: 12,
          reputation: 5,
          morale: 50,
          condition: 100,
          status: :active,
          external_source: source,
          external_id:,
          **Athlete::ATTRIBUTES.index_with { 10 }
        )
      end

      def create_current_contract(athlete, club, source)
        AthleteContract.create!(
          athlete:,
          club:,
          start_date: Date.new(2026, 1, 1),
          end_date: Date.new(2028, 1, 1),
          wage: 1_000,
          status: :active,
          current: true,
          loan: false,
          external_source: source,
          external_id: "contract:#{athlete.external_id}"
        )
      end
    end
  end
end
