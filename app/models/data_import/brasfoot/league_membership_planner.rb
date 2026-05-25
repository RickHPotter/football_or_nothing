# frozen_string_literal: true

module DataImport
  module Brasfoot
    class LeagueMembershipPlanner
      DEFAULT_TEAMS_PATH = Pathname("/media/lovelace/01D8A2DEE1DFF560/REAL BRASFOOT 2026/teams")

      PlannedDivision = Struct.new(:division, :teams, keyword_init: true)
      PlannedTeam = Struct.new(:external_id, :name, :source, :ranking_fields, keyword_init: true)

      def self.call(...)
        new(...).call
      end

      def initialize(config_path:, teams_path: DEFAULT_TEAMS_PATH)
        @config = LeagueConfigParser.call(config_path)
        @teams_path = Pathname(teams_path)
        @source = PackImporter::DEFAULT_SOURCE
      end

      def call
        remaining_teams = ranked_teams.dup

        config.divisions.map do |division|
          PlannedDivision.new(
            division:,
            teams: remaining_teams.shift(division.team_count.to_i)
          )
        end
      end

      private

      attr_reader :config, :teams_path

      def ranked_teams
        team_rows.sort_by do |team|
          fields = team.ranking_fields
          [
            -fields.fetch("n").to_i,
            -fields.fetch("c").to_i,
            -fields.fetch("g").to_i,
            team.name
          ]
        end
      end

      def team_rows
        Pathname.glob(teams_path.join("*.ban").to_s).filter_map do |path|
          next unless java_serialization_file?(path)

          team = TeamFileParser.call(path)
          fields = team.raw_fields
          next unless fields["a"] == country_id

          PlannedTeam.new(
            external_id: team.external_id,
            name: team.name,
            source: @source,
            ranking_fields: fields.slice("b", "c", "g", "i", "id", "n", "o")
          )
        rescue ArgumentError
          nil
        end
      end

      def country_id
        @country_id ||= config.divisions.first&.raw_fields&.fetch("pais")
      end

      def java_serialization_file?(path)
        path.binread(4) == "\xAC\xED\x00\x05".b
      end
    end
  end
end
