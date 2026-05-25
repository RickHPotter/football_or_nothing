# frozen_string_literal: true

require "test_helper"

module DataImport
  module Brasfoot
    class LeagueImporterTest < ActiveSupport::TestCase
      test "imports planned divisions as tournaments editions participations and fixtures" do
        country = countries(:one)
        country.update!(name: "Brazil", code: "BRA", external_source: "brasfoot_pack", external_id: "BRA")
        teams_path = Rails.root.join("tmp", "brasfoot_league_importer_test")
        FileUtils.rm_rf(teams_path)
        FileUtils.mkdir_p(teams_path)

        %w[alpha beta gamma delta].each_with_index do |external_id, index|
          create_brasfoot_club(country, external_id, "#{external_id.titleize} FC")
          File.binwrite(teams_path.join("#{external_id}.ban"), "\xAC\xED\x00\x05".b)
          raw_fields = {
            "a" => PackImporter::BRAZIL_COUNTRY_ID,
            "b" => 0,
            "c" => 20 - index,
            "g" => 10_000 - index,
            "i" => 29,
            "id" => index,
            "n" => 5 - index,
            "o" => 0
          }
          teams[external_id] = parsed_team(external_id, "#{external_id.titleize} FC", raw_fields)
        end

        assert_difference [ "Tournament.count", "TournamentEdition.count" ], 2 do
          with_brasfoot_stubs(teams) do
            LeagueImporter.call(config_path: "BRA.cfg", teams_path:, season_year: 2026)
          end
        end

        edition = Tournament.find_by!(name: "Brasileirao Serie A").tournament_editions.find_by!(season_year: 2026)
        assert_equal 2, edition.clubs.count
        assert_equal 2, edition.fixtures.count
        assert DataImportRun.last.completed?

        with_brasfoot_stubs(teams) do
          assert_no_difference [ "Tournament.count", "TournamentEdition.count", "TournamentParticipation.count", "Fixture.count" ] do
            LeagueImporter.call(config_path: "BRA.cfg", teams_path:, season_year: 2026)
          end
        end
      ensure
        FileUtils.rm_rf(teams_path) if teams_path
      end

      private

      def create_brasfoot_club(country, external_id, name)
        Club.create!(
          country:,
          name:,
          short_name: name.split.map(&:first).join,
          reputation: 10,
          academy_quality: 10,
          external_source: "brasfoot_pack",
          external_id:
        ).tap do |club|
          club.stadiums.create!(
            country:,
            name: "#{name} Ground",
            city: "Rio",
            capacity: 10_000,
            pitch_quality: 10,
            ownership: :club_owned
          )
        end
      end

      def teams
        @teams ||= {}
      end

      def parsed_team(external_id, name, raw_fields)
        TeamFileParser::ParsedTeam.new(
          external_id:,
          name:,
          short_name: external_id,
          stadium_name: "#{name} Ground",
          city: "Rio",
          manager_name: "Manager",
          players: [],
          raw_fields:
        )
      end

      def with_brasfoot_stubs(teams)
        original_config_call = LeagueConfigParser.method(:call)
        original_team_call = TeamFileParser.method(:call)
        config = test_config

        LeagueConfigParser.define_singleton_method(:call) { |_path| config }
        TeamFileParser.define_singleton_method(:call) do |path|
          teams.fetch(Pathname(path).basename(".ban").to_s)
        end

        yield
      ensure
        LeagueConfigParser.define_singleton_method(:call, original_config_call)
        TeamFileParser.define_singleton_method(:call, original_team_call)
      end

      def test_config
        LeagueConfigParser::ParsedConfig.new(
          path: "BRA.cfg",
          kind: :national,
          name: "BRA",
          divisions: [
            test_division("Brasileirao Serie A", 1, 2),
            test_division("Brasileirao Serie B", 2, 2)
          ],
          raw_object: nil
        )
      end

      def test_division(name, division, team_count)
        LeagueConfigParser::ParsedDivision.new(
          name:,
          division:,
          team_count:,
          relegated_count: 0,
          format: 0,
          raw_fields: { "pais" => PackImporter::BRAZIL_COUNTRY_ID }
        )
      end
    end
  end
end
