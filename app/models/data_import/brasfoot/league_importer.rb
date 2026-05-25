# frozen_string_literal: true

module DataImport
  module Brasfoot
    class LeagueImporter
      DEFAULT_SOURCE = "brasfoot_league"
      DEFAULT_SEASON_YEAR = 2026
      DEFAULT_STARTS_ON = Date.new(2026, 5, 1)
      CONFIG_COUNTRIES = PackImporter::COUNTRIES_BY_SUFFIX.merge(
        "afg" => [ "Afghanistan", "AFG" ],
        "afs" => [ "South Africa", "ZAF" ],
        "ars" => [ "Saudi Arabia", "KSA" ],
        "aus" => [ "Australia", "AUS" ],
        "aze" => [ "Azerbaijan", "AZE" ],
        "bul" => [ "Bulgaria", "BUL" ],
        "cat" => [ "Qatar", "QAT" ],
        "crs" => [ "Costa Rica", "CRC" ],
        "din" => [ "Denmark", "DEN" ],
        "emi" => [ "United Arab Emirates", "UAE" ],
        "equ" => [ "Ecuador", "ECU" ],
        "hun" => [ "Hungary", "HUN" ],
        "mal" => [ "Malaysia", "MAS" ],
        "mar" => [ "Morocco", "MAR" ],
        "rtc" => [ "Czech Republic", "CZE" ],
        "ser" => [ "Serbia", "SRB" ],
        "tai" => [ "Thailand", "THA" ],
        "ucr" => [ "Ukraine", "UKR" ]
      ).freeze

      def self.call(...)
        new(...).call
      end

      def initialize(config_path:, teams_path: LeagueMembershipPlanner::DEFAULT_TEAMS_PATH, source: DEFAULT_SOURCE,
                     club_source: PackImporter::DEFAULT_SOURCE, season_year: DEFAULT_SEASON_YEAR)
        @config_path = Pathname(config_path)
        @teams_path = Pathname(teams_path)
        @source = source
        @club_source = club_source
        @season_year = season_year.to_i
      end

      def call
        DataImportRun.transaction do
          import_run
          imported_editions = planned_divisions.filter_map { |planned_division| import_division(planned_division) }
          import_run.complete!(records_processed: imported_record_count(imported_editions))
          imported_editions
        end
      rescue StandardError => error
        import_run.fail!(notes: error.message) if import_run&.persisted? && import_run.running?
        raise
      end

      private

      attr_reader :config_path, :teams_path, :source, :club_source, :season_year

      def import_run
        @import_run ||= DataImportRun.create!(source: "#{source}:#{config.name}:#{season_year}", started_at: Time.current)
      end

      def import_division(planned_division)
        clubs = clubs_for(planned_division)
        return if clubs.empty?

        tournament = tournament_for(planned_division.division)
        edition = edition_for(tournament, planned_division.division, clubs.length)
        LeagueScheduler.call(edition, clubs)
        edition
      end

      def tournament_for(division)
        country.tournaments.find_or_initialize_by(name: tournament_name_for(division)).tap do |tournament|
          tournament.short_name = short_name_for(tournament.name)
          tournament.scope = :domestic
          tournament.format = :league
          tournament.status = :active
          tournament.save!
        end
      end

      def edition_for(tournament, division, club_count)
        tournament.tournament_editions.find_or_initialize_by(season_year:).tap do |edition|
          edition.name = "#{tournament.name} #{season_year}"
          edition.starts_on = DEFAULT_STARTS_ON + (division.division.to_i - 1).weeks
          edition.ends_on = edition.starts_on + (((club_count - 1) * 2) - 1).weeks
          edition.status = :scheduled
          edition.save!
        end
      end

      def clubs_for(planned_division)
        planned_division.teams.filter_map do |team|
          club = Club.find_by(external_source: club_source, external_id: team.external_id)
          next unless club

          ensure_default_stadium(club)
          club
        end
      end

      def ensure_default_stadium(club)
        return if club.stadiums.exists?

        club.stadiums.create!(
          country: club.country,
          name: "#{club.name} Ground",
          city: club.country.name,
          capacity: 10_000,
          pitch_quality: 10,
          ownership: :club_owned
        )
      end

      def country
        @country ||= Country.find_or_initialize_by(code: country_code).tap do |record|
          record.name ||= country_name
          record.external_source ||= source
          record.external_id ||= country_code
          record.reputation ||= 5
          record.status ||= :active
          record.save!
        end
      end

      def country_code
        country_identity.last
      end

      def country_name
        country_identity.first
      end

      def country_identity
        return [ "Brazil", "BRA" ] if config.kind == :state
        return [ "Brazil", "BRA" ] if config.divisions.first&.raw_fields&.fetch("pais", nil) == PackImporter::BRAZIL_COUNTRY_ID

        CONFIG_COUNTRIES.fetch(config.name.downcase, [ config.name, config.name ])
      end

      def planned_divisions
        @planned_divisions ||= LeagueMembershipPlanner.call(config_path:, teams_path:)
      end

      def config
        @config ||= LeagueConfigParser.call(config_path)
      end

      def short_name_for(name)
        name.split.map { |word| word.first.upcase }.join.first(12)
      end

      def tournament_name_for(division)
        return division.name unless config.kind == :state

        "Campeonato #{config.name} Division #{division.division}"
      end

      def imported_record_count(editions)
        editions.sum { |edition| 1 + edition.tournament_participations.count + edition.fixtures.count }
      end
    end
  end
end
