# frozen_string_literal: true

module DataImport
  module Brasfoot
    class TeamTournamentProbe
      DEFAULT_PACK_PATH = Pathname("/media/lovelace/01D8A2DEE1DFF560/REAL BRASFOOT 2026")

      TeamReport = Struct.new(:team, :country_suffix, :national_config, :state_config, :candidate_national_division,
                              :candidate_state_division, :raw_team_fields, keyword_init: true)

      def self.call(...)
        new(...).call
      end

      def initialize(team_path:, pack_path: DEFAULT_PACK_PATH)
        @team_path = Pathname(team_path)
        @pack_path = Pathname(pack_path)
      end

      def call
        team = TeamFileParser.call(team_path)
        TeamReport.new(
          team:,
          country_suffix: country_suffix_for(team),
          national_config: parse_if_present(national_config_path(team)),
          state_config: parse_if_present(state_config_path(team)),
          candidate_national_division: candidate_national_division(team),
          candidate_state_division: candidate_state_division(team),
          raw_team_fields: team.raw_fields.except("l", "m")
        )
      end

      private

      attr_reader :team_path, :pack_path

      def parse_if_present(path)
        return unless path&.exist?

        LeagueConfigParser.call(path)
      rescue ArgumentError
        nil
      end

      def national_config_path(team)
        code = national_config_code_for(team.external_id)
        return unless code

        pack_path.join("conf_ligas_nacionais", "#{code.upcase}.cfg")
      end

      def state_config_path(team)
        suffix = state_suffix_for(team)
        return unless brazil_state_suffix?(suffix)

        pack_path.join("conf_estadual", "#{suffix.upcase}.ces")
      end

      def national_config_code_for(external_id)
        return "BRA" if team_country_id == PackImporter::BRAZIL_COUNTRY_ID

        suffix = country_suffix_from_external_id(external_id)
        suffix
      end

      def candidate_national_division(team)
        team.raw_fields["n"]
      end

      def candidate_state_division(team)
        team.raw_fields["o"]
      end

      def country_suffix_for(team)
        return state_suffix_for(team) if team.raw_fields["a"] == PackImporter::BRAZIL_COUNTRY_ID

        country_suffix_from_external_id(team.external_id)
      end

      def country_suffix_from_external_id(external_id)
        PackImporter.new(path: team_path).send(:country_suffix_for, external_id)
      end

      def state_suffix_for(team)
        PackImporter.new(path: team_path).send(:brazil_state_suffix_for, team.external_id)
      end

      def team_country_id
        @team_country_id ||= TeamFileParser.call(team_path).raw_fields["a"]
      end

      def brazil_state_suffix?(suffix)
        PackImporter::BRAZIL_STATE_SUFFIXES.include?(suffix)
      end
    end
  end
end
