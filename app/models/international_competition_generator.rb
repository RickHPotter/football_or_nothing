# frozen_string_literal: true

class InternationalCompetitionGenerator
  FIRST_NAMES = %w[Alex Ben Carlo Diego Emil Felix Gio Hugo Ivo Joel].freeze
  LAST_NAMES = %w[Silva Costa Ramos Torres Vega Marin Alves Dias Cruz Mora].freeze
  POSITIONS = Athlete.defined_enums.fetch("position").keys.freeze

  def self.call(...)
    new(...).call
  end

  def initialize(countries:, season_year:, starts_on:, ends_on:, host_country: nil)
    @countries = countries
    @season_year = season_year
    @starts_on = starts_on
    @ends_on = ends_on
    @host_country = host_country || countries.first
  end

  def call
    TournamentEdition.transaction do
      teams = countries.map { |country| national_team_for(country) }
      edition = tournament.tournament_editions.find_or_create_by!(season_year:) do |record|
        record.name = "#{tournament.name} #{season_year}"
        record.starts_on = starts_on
        record.ends_on = ends_on
        record.status = :scheduled
      end

      LeagueScheduler.call(edition, teams) if edition.fixtures.none?
      edition
    end
  end

  private

  attr_reader :countries, :season_year, :starts_on, :ends_on, :host_country

  def tournament
    host_country.tournaments.find_or_create_by!(name: "World Nations League") do |record|
      record.short_name = "WNL"
      record.scope = :international
      record.format = :league
      record.status = :active
    end
  end

  def national_team_for(country)
    club = country.clubs.find_or_create_by!(name: "#{country.name} National Team") do |record|
      record.short_name = country.code.first(3).upcase
      record.reputation = country.reputation
      record.founded_year = 1900
      record.international = true
      record.status = :active
    end
    club.create_club_finance! unless club.club_finance
    ensure_stadium(country, club)
    ensure_squad(country, club)
    club
  end

  def ensure_stadium(country, club)
    return if club.stadiums.exists?

    club.stadiums.create!(
      country:,
      name: "#{country.name} National Stadium",
      city: country.name,
      capacity: 25_000 + (country.reputation * 1_000),
      pitch_quality: [ country.reputation + 8, 20 ].min,
      ownership: :municipal
    )
  end

  def ensure_squad(country, club)
    return if club.current_athlete_contracts.count >= 18

    18.times do |index|
      athlete = international_athlete(country, index)
      next if athlete.current_club

      club.athlete_contracts.create!(
        athlete:,
        start_date: starts_on - 15.days,
        end_date: ends_on,
        wage: 0,
        status: :active
      )
    end
  end

  def international_athlete(country, index)
    ability = [ country.reputation + (index % 5), 20 ].min
    Athlete.find_or_create_by!(
      country:,
      first_name: FIRST_NAMES[index % FIRST_NAMES.length],
      last_name: "#{LAST_NAMES[(country.id + index) % LAST_NAMES.length]} NT#{index + 1}"
    ) do |athlete|
      athlete.birthdate = Date.new(season_year - 22 - (index % 10), (index % 12) + 1, ((index * 2) % 27) + 1)
      athlete.position = POSITIONS[index % POSITIONS.length]
      athlete.preferred_foot = index.even? ? :right : :left
      athlete.current_ability = ability
      athlete.potential_ability = [ ability + 2, 20 ].min
      athlete.reputation = [ ability - 1, 1 ].max
      athlete.morale = 60
      athlete.condition = 100
      Athlete::ATTRIBUTES.each { |attribute| athlete.public_send("#{attribute}=", ability) }
    end
  end
end
