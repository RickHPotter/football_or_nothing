# frozen_string_literal: true

module DataImport
  module Brasfoot
    class AuditReport
      DEFAULT_LIMIT = 20
      ASSET_NAMES = %w[crest mini_crest home_shirt away_shirt third_shirt].freeze

      Result = Struct.new(:source, :league_source, :summary, :issues, :issue_counts, keyword_init: true) do
        def to_text
          lines = [
            "[brasfoot:audit] source=#{source}",
            "",
            "Summary"
          ]

          summary.each { |key, value| lines << "- #{key.to_s.humanize}: #{value}" }

          lines << ""
          lines << "Issues"
          issues.each do |key, values|
            lines << "- #{key.to_s.humanize}: #{issue_counts.fetch(key, values.size)}"
            values.each { |value| lines << "  - #{format_issue(value)}" }
          end

          lines.join("\n")
        end

        private

        def format_issue(value)
          return value unless value.is_a?(Hash)

          value.map { |key, item| "#{key}=#{item}" }.join(" | ")
        end
      end

      def self.call(...)
        new(...).call
      end

      def initialize(source: PackImporter::DEFAULT_SOURCE, league_source: LeagueImporter::DEFAULT_SOURCE, limit: DEFAULT_LIMIT)
        @source = source
        @league_source = league_source
        @limit = limit.to_i
      end

      def call
        Result.new(
          source:,
          league_source:,
          summary:,
          issues:,
          issue_counts:
        )
      end

      private

      attr_reader :source, :league_source, :limit

      def summary
        {
          countries: imported_countries.count,
          clubs: clubs.count,
          athletes: athletes.count,
          contracts: contracts.count,
          stadiums: Stadium.where(club_id: clubs.select(:id)).count,
          tournaments: tournaments.count,
          editions: editions.count,
          participations: TournamentParticipation.where(tournament_edition_id: editions.select(:id)).count,
          fixtures: Fixture.where(tournament_edition_id: editions.select(:id)).count,
          club_assets: asset_count,
          fallback_country_clubs: fallback_country_clubs.count
        }
      end

      def issues
        {
          fallback_country_clubs: issue_clubs(fallback_country_clubs),
          clubs_without_stadiums: issue_clubs(clubs_without_stadiums),
          clubs_without_crests: issue_clubs(clubs_missing_asset("crest")),
          clubs_without_home_shirts: issue_clubs(clubs_missing_asset("home_shirt")),
          athletes_without_current_contracts: issue_athletes(athletes_without_current_contracts),
          duplicate_club_names: duplicate_club_names,
          duplicate_stadium_names: duplicate_stadium_names,
          tournaments_without_editions: issue_tournaments(tournaments_without_editions),
          editions_without_clubs: issue_editions(editions_without_clubs),
          editions_with_suspicious_fixture_counts: suspicious_fixture_counts
        }
      end

      def issue_counts
        {
          fallback_country_clubs: fallback_country_clubs.count,
          clubs_without_stadiums: clubs_without_stadiums.count,
          clubs_without_crests: clubs_missing_asset("crest").count,
          clubs_without_home_shirts: clubs_missing_asset("home_shirt").count,
          athletes_without_current_contracts: athletes_without_current_contracts.count,
          duplicate_club_names: duplicate_club_name_rows.size,
          duplicate_stadium_names: duplicate_stadium_name_rows.size,
          tournaments_without_editions: tournaments_without_editions.count,
          editions_without_clubs: editions_without_clubs.count,
          editions_with_suspicious_fixture_counts: suspicious_fixture_count_rows.size
        }
      end

      def imported_countries
        @imported_countries ||= Country.where(external_source: [ source, league_source ])
      end

      def imported_country_ids
        @imported_country_ids ||= (imported_countries.pluck(:id) + clubs.distinct.pluck(:country_id)).uniq
      end

      def clubs
        @clubs ||= Club.where(external_source: source)
      end

      def athletes
        @athletes ||= Athlete.where(external_source: source)
      end

      def contracts
        @contracts ||= AthleteContract.where(external_source: source)
      end

      def tournaments
        @tournaments ||= Tournament.where(country_id: imported_country_ids)
      end

      def editions
        @editions ||= TournamentEdition.joins(:tournament).where(tournaments: { country_id: imported_country_ids })
      end

      def fallback_country_clubs
        @fallback_country_clubs ||= clubs.joins(:country).where(countries: { code: PackImporter::DEFAULT_COUNTRY_CODE })
      end

      def clubs_without_stadiums
        @clubs_without_stadiums ||= clubs.left_outer_joins(:stadiums).where(stadiums: { id: nil })
      end

      def clubs_missing_asset(asset_name)
        @clubs_missing_asset ||= {}
        @clubs_missing_asset[asset_name] ||= begin
        attached_ids = ActiveStorage::Attachment.where(
          record_type: "Club",
          record_id: clubs.select(:id),
          name: asset_name
        ).select(:record_id)

        clubs.where.not(id: attached_ids)
        end
      end

      def athletes_without_current_contracts
        @athletes_without_current_contracts ||= athletes
          .left_outer_joins(:current_athlete_contract)
          .where(athlete_contracts: { id: nil })
      end

      def tournaments_without_editions
        @tournaments_without_editions ||= tournaments.left_outer_joins(:tournament_editions).where(tournament_editions: { id: nil })
      end

      def editions_without_clubs
        @editions_without_clubs ||= editions.left_outer_joins(:tournament_participations).where(tournament_participations: { id: nil })
      end

      def asset_count
        ActiveStorage::Attachment.where(
          record_type: "Club",
          record_id: clubs.select(:id),
          name: ASSET_NAMES
        ).count
      end

      def issue_clubs(relation)
        relation.includes(:country).order(:name).limit(limit).map do |club|
          { club: club.name, country: club.country.code, external_id: club.external_id }
        end
      end

      def issue_athletes(relation)
        relation.includes(:country).order(:last_name, :first_name).limit(limit).map do |athlete|
          { athlete: "#{athlete.first_name} #{athlete.last_name}", country: athlete.country.code, external_id: athlete.external_id }
        end
      end

      def issue_tournaments(relation)
        relation.includes(:country).order(:name).limit(limit).map do |tournament|
          { tournament: tournament.name, country: tournament.country.code }
        end
      end

      def issue_editions(relation)
        relation.includes(:tournament).order(:season_year, :name).limit(limit).map do |edition|
          { edition: edition.name, tournament: edition.tournament.name, season_year: edition.season_year }
        end
      end

      def duplicate_club_names
        duplicate_club_name_rows
          .first(limit)
          .map do |(country_id, name), count|
            { club: name, country: Country.find(country_id).code, count: }
          end
      end

      def duplicate_stadium_names
        duplicate_stadium_name_rows
          .first(limit)
          .map do |(country_id, name), count|
            { stadium: name, country: Country.find(country_id).code, count: }
          end
      end

      def suspicious_fixture_counts
        suspicious_fixture_count_rows.first(limit)
      end

      def duplicate_club_name_rows
        @duplicate_club_name_rows ||= clubs
          .select(:country_id, :name)
          .group(:country_id, :name)
          .having("COUNT(*) > 1")
          .count(:id)
      end

      def duplicate_stadium_name_rows
        @duplicate_stadium_name_rows ||= Stadium
          .where(club_id: clubs.select(:id))
          .select(:country_id, :name)
          .group(:country_id, :name)
          .having("COUNT(*) > 1")
          .count(:id)
      end

      def suspicious_fixture_count_rows
        @suspicious_fixture_count_rows ||= begin
        editions
          .includes(:tournament)
          .limit(nil)
          .filter_map do |edition|
            club_count = edition.tournament_participations.count
            next if club_count < 2

            expected_fixture_count = club_count * (club_count - 1)
            actual_fixture_count = edition.fixtures.count
            next if actual_fixture_count == expected_fixture_count

            {
              edition: edition.name,
              clubs: club_count,
              fixtures: actual_fixture_count,
              expected_fixtures: expected_fixture_count
            }
          end
        end
      end
    end
  end
end
