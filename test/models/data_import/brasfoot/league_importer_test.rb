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

      test "resolves brasfoot config country codes before importing tournaments" do
        pack_country = countries(:one)
        pack_country.update!(name: "Brasfoot Pack", code: "BFP", external_source: "brasfoot_pack", external_id: "BFP")
        teams_path = Rails.root.join("tmp", "brasfoot_league_importer_country_test")
        FileUtils.rm_rf(teams_path)
        FileUtils.mkdir_p(teams_path)

        %w[alpha beta].each_with_index do |external_id, index|
          create_brasfoot_club(pack_country, external_id, "#{external_id.titleize} FC")
          File.binwrite(teams_path.join("#{external_id}.ban"), "\xAC\xED\x00\x05".b)
          teams[external_id] = parsed_team(
            external_id,
            "#{external_id.titleize} FC",
            {
              "a" => 1,
              "b" => 0,
              "c" => 20 - index,
              "g" => 10_000 - index,
              "i" => 1,
              "id" => index,
              "n" => 5 - index,
              "o" => 0
            }
          )
        end

        with_brasfoot_stubs(teams, config: test_config(name: "ALE", country_id: 1)) do
          LeagueImporter.call(config_path: "ALE.cfg", teams_path:, season_year: 2026)
        end

        country = Country.find_by!(code: "GER")
        assert_equal "Germany", country.name
        assert_equal country, Tournament.find_by!(name: "Brasileirao Serie A").country
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

      def with_brasfoot_stubs(teams, config: test_config)
        original_config_call = LeagueConfigParser.method(:call)
        original_team_call = TeamFileParser.method(:call)

        LeagueConfigParser.define_singleton_method(:call) { |_path| config }
        TeamFileParser.define_singleton_method(:call) do |path|
          teams.fetch(Pathname(path).basename(".ban").to_s)
        end

        yield
      ensure
        LeagueConfigParser.define_singleton_method(:call, original_config_call)
        TeamFileParser.define_singleton_method(:call, original_team_call)
      end

      def test_config(name: "BRA", country_id: PackImporter::BRAZIL_COUNTRY_ID)
        LeagueConfigParser::ParsedConfig.new(
          path: "#{name}.cfg",
          kind: :national,
          name:,
          divisions: [
            test_division("Brasileirao Serie A", 1, 2, country_id:),
            test_division("Brasileirao Serie B", 2, 2, country_id:)
          ],
          raw_object: nil
        )
      end

      def test_division(name, division, team_count, country_id: PackImporter::BRAZIL_COUNTRY_ID)
        LeagueConfigParser::ParsedDivision.new(
          name:,
          division:,
          team_count:,
          relegated_count: 0,
          format: 0,
          raw_fields: { "pais" => country_id }
        )
      end
    end
  end
end
