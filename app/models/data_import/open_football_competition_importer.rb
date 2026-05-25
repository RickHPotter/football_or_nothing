# frozen_string_literal: true

module DataImport
  class OpenFootballCompetitionImporter
    DEFAULT_KICKOFF_MINUTE = 900

    def self.call(...)
      new(...).call
    end

    def initialize(source:, payload:, country_name:, country_code:, competition_name: nil, short_name: nil)
      @source = source
      @payload = payload.deep_symbolize_keys
      @country_name = country_name
      @country_code = country_code
      @competition_name = competition_name
      @short_name = short_name
    end

    def call
      DataImportRun.transaction do
        import_run
        import_country
        import_tournament
        import_edition
        import_clubs_and_fixtures
        import_run.complete!(records_processed: imported_records_count)
        edition
      end
    rescue StandardError => error
      import_run.fail!(notes: error.message) if import_run&.persisted? && import_run.running?
      raise
    end

    private

    attr_reader :source, :payload, :country_name, :country_code, :competition_name, :short_name

    def import_run
      @import_run ||= DataImportRun.create!(source:, started_at: Time.current)
    end

    def import_country
      @country ||= Country.find_or_initialize_by(external_source: source, external_id: country_code).tap do |country|
        country.name = country_name
        country.code = country_code
        country.reputation ||= 8
        country.status = :active
        country.save!
      end
    end

    def import_tournament
      @tournament ||= country.tournaments.find_or_initialize_by(name: resolved_competition_name).tap do |tournament|
        tournament.short_name = short_name.presence || resolved_competition_name.split.map { |word| word.first.upcase }.join.first(6)
        tournament.scope = :domestic
        tournament.format = :league
        tournament.status = :active
        tournament.save!
      end
    end

    def import_edition
      @edition ||= tournament.tournament_editions.find_or_initialize_by(season_year:).tap do |edition|
        edition.name = "#{tournament.name} #{season_year}"
        edition.starts_on = match_dates.min
        edition.ends_on = match_dates.max
        edition.status = fixtures_completed? ? :completed : :scheduled
        edition.save!
      end
    end

    def import_clubs_and_fixtures
      matches.each_with_index do |match, index|
        home_club = club_for(match.fetch(:team1))
        away_club = club_for(match.fetch(:team2))
        ensure_participation(home_club)
        ensure_participation(away_club)
        import_fixture(match, index + 1, home_club, away_club)
      end
    end

    def import_fixture(match, fallback_round, home_club, away_club)
      fixture = edition.fixtures.find_or_initialize_by(home_club:, away_club:)
      fixture.stadium = default_stadium_for(home_club)
      fixture.scheduled_on = Date.parse(match.fetch(:date).to_s)
      fixture.kickoff_minute = DEFAULT_KICKOFF_MINUTE
      fixture.round = match[:round].presence || fallback_round
      apply_score(fixture, match[:score])
      fixture.save!
      fixture
    end

    def apply_score(fixture, score)
      if score.present?
        fixture.home_goals = score.fetch(:ft).fetch(0)
        fixture.away_goals = score.fetch(:ft).fetch(1)
        fixture.status = :completed
      else
        fixture.status = :scheduled
      end
    end

    def club_for(name)
      club_external_id = "club:#{name.parameterize}"
      country.clubs.find_or_initialize_by(external_source: source, external_id: club_external_id).tap do |club|
        club.name = name
        club.short_name = name.split.map { |word| word.first.upcase }.join.first(6)
        club.reputation ||= 5
        club.status = :active
        club.save!
        club.create_club_finance! unless club.club_finance
        default_stadium_for(club)
      end
    end

    def default_stadium_for(club)
      club.stadiums.first || club.stadiums.create!(
        country:,
        name: "#{club.name} Ground",
        city: country.name,
        capacity: 10_000,
        pitch_quality: 10,
        ownership: :club_owned
      )
    end

    def ensure_participation(club)
      edition.tournament_participations.find_or_create_by!(club:)
    end

    def imported_records_count
      1 + 1 + 1 + edition.clubs.count + edition.fixtures.count
    end

    def fixtures_completed?
      matches.all? { |match| match[:score].present? }
    end

    def resolved_competition_name
      competition_name.presence || payload[:name].presence || payload[:league].presence || "OpenFootball League"
    end

    def season_year
      @season_year ||= payload[:season].to_s[/\d{4}/].to_i
    end

    def match_dates
      @match_dates ||= matches.map { |match| Date.parse(match.fetch(:date).to_s) }
    end

    def matches
      @matches ||= Array(payload.fetch(:matches))
    end

    def country
      @country ||= import_country
    end

    def tournament
      @tournament ||= import_tournament
    end

    def edition
      @edition ||= import_edition
    end
  end
end
