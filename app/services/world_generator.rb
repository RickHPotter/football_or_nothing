class WorldGenerator
  CLUBS = [
    [ "Aurora FC", "AUR", "Aurora Park", "Capital" ],
    [ "Estrela SC", "EST", "Estrela Ground", "Porto Novo" ],
    [ "Riverside United", "RIV", "Riverside Arena", "Ribeira" ],
    [ "Ferroviario City", "FER", "Railway Stadium", "Linha Alta" ],
    [ "Atletico Litoral", "ATL", "Litoral Bowl", "Mar Azul" ],
    [ "Monte Verde", "MON", "Monte Verde Field", "Serra" ],
    [ "Norte Real", "NOR", "Norte Real Stadium", "Norte" ],
    [ "Sul Independente", "SUL", "Independencia Park", "Sul" ]
  ].freeze

  FIRST_NAMES = %w[
    Adrian Bruno Caio Daniel Elias Fabio Gabriel Hugo Ivan Jonas Lucas Marco
    Nicolas Otavio Paulo Rafael Samuel Tiago Victor Wesley Yuri
  ].freeze

  LAST_NAMES = %w[
    Almeida Barbosa Castro Duarte Esteves Farias Gomes Lima Martins Nogueira
    Oliveira Pereira Rocha Santos Teixeira Vieira
  ].freeze

  POSITIONS = Athlete.positions.keys.freeze
  ATTRIBUTES = Athlete::ATTRIBUTES

  def self.call(...)
    new(...).call
  end

  def initialize(country_name: "Brasilia", country_code: "BRA")
    @country_name = country_name
    @country_code = country_code
  end

  def call
    country = Country.find_or_create_by!(code: @country_code) do |record|
      record.name = @country_name
      record.reputation = 8
      record.status = :active
    end

    CLUBS.each.with_index(1) do |club_data, index|
      create_club(country, club_data, index)
    end

    create_league(country)

    country
  end

  private
    def create_league(country)
      tournament = country.tournaments.find_or_create_by!(name: "Brasilia Premier League") do |record|
        record.short_name = "BPL"
        record.scope = :domestic
        record.format = :league
        record.status = :active
      end

      edition = tournament.tournament_editions.find_or_create_by!(season_year: 2026) do |record|
        record.name = "Brasilia Premier League 2026"
        record.starts_on = Date.new(2026, 2, 1)
        record.ends_on = Date.new(2026, 5, 3)
        record.status = :scheduled
      end

      LeagueScheduler.call(edition, country.clubs.active.order(:name))
    end

    def create_club(country, club_data, index)
      name, short_name, stadium_name, city = club_data
      club = country.clubs.find_or_create_by!(name:) do |record|
        record.short_name = short_name
        record.reputation = 4 + index
        record.founded_year = 1900 + (index * 7)
        record.status = :active
      end

      club.create_club_finance! unless club.club_finance
      update_finance(club.club_finance, index)
      create_stadium(country, club, stadium_name, city, index)
      create_squad(country, club, index)
    end

    def update_finance(finance, index)
      finance.update!(
        cash_balance: 1_000_000 + (index * 125_000),
        wage_budget: 90_000 + (index * 7_500),
        transfer_budget: 250_000 + (index * 50_000),
        sponsorship_income: 120_000 + (index * 15_000),
        stadium_income: 40_000 + (index * 7_500),
        expenses: 80_000 + (index * 6_000)
      )
    end

    def create_stadium(country, club, name, city, index)
      club.stadiums.find_or_create_by!(name:) do |record|
        record.country = country
        record.city = city
        record.capacity = 8_000 + (index * 1_500)
        record.pitch_quality = [ 8 + index, 20 ].min
        record.ownership = :club_owned
      end
    end

    def create_squad(country, club, club_index)
      return if club.athlete_contracts.where(current: true).count >= 22

      22.times do |squad_index|
        athlete = create_athlete(country, club_index, squad_index)
        next if athlete.athlete_contracts.where(current: true).exists?

        club.athlete_contracts.create!(
          athlete:,
          start_date: Date.new(2026, 1, 1),
          end_date: Date.new(2028, 12, 31),
          wage: 2_500 + (athlete.current_ability * 300),
          squad_number: squad_index + 1,
          status: :active
        )
      end
    end

    def create_athlete(country, club_index, squad_index)
      first_name = FIRST_NAMES[(club_index + squad_index) % FIRST_NAMES.length]
      last_name = LAST_NAMES[(club_index * 3 + squad_index) % LAST_NAMES.length]
      birth_year = 1989 + ((club_index + squad_index) % 16)
      ability = 4 + ((club_index + squad_index) % 9)

      Athlete.find_or_create_by!(
        country:,
        first_name:,
        last_name: "#{last_name} #{club_index}-#{squad_index + 1}"
      ) do |record|
        record.birthdate = Date.new(birth_year, (squad_index % 12) + 1, ((squad_index * 2) % 27) + 1)
        record.position = POSITIONS[position_index(squad_index)]
        record.preferred_foot = squad_index.even? ? :right : :left
        record.height_cm = 170 + (squad_index % 23)
        record.weight_kg = 65 + (squad_index % 21)
        record.current_ability = ability
        record.potential_ability = [ ability + 4, 20 ].min
        record.reputation = [ ability - 2, 1 ].max
        assign_attributes(record, ability, squad_index)
      end
    end

    def assign_attributes(record, ability, squad_index)
      ATTRIBUTES.each.with_index do |attribute, index|
        record.public_send("#{attribute}=", [ ability + ((squad_index + index) % 5), 20 ].min)
      end
    end

    def position_index(squad_index)
      case squad_index
      when 0, 1 then 0
      when 2..5 then 1
      when 6..8 then 2
      when 9..10 then 3
      when 11..13 then 4
      when 14..15 then 5
      when 16..18 then 6
      else 7
      end
    end
end
