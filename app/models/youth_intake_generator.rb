class YouthIntakeGenerator
  FIRST_NAMES = %w[Leo Rafa Theo Nico Davi Enzo Iago Caio Luan Tom].freeze
  LAST_NAMES = %w[Almeida Costa Rocha Lima Martins Souza Ribeiro Duarte Cardoso Mendes].freeze
  POSITIONS = Athlete.defined_enums.fetch("position").keys.freeze

  def self.call(...)
    new(...).call
  end

  def initialize(club:, season_year:, generated_on:, count: 5)
    @club = club
    @season_year = season_year
    @generated_on = generated_on
    @count = count
  end

  def call
    YouthIntake.transaction do
      intake = YouthIntake.find_or_create_by!(club:, season_year:) do |record|
        record.generated_on = generated_on
      end
      return intake if intake.athletes.any?

      count.times { |index| create_athlete!(intake, index) }
      publish_news!(intake)
      intake
    end
  end

  private
    attr_reader :club, :season_year, :generated_on, :count

    def create_athlete!(intake, index)
      current_ability = [ base_ability + (index % 2), 20 ].min
      potential_ability = [ current_ability + potential_gap(index), 20 ].min

      intake.athletes.create!(
        country: club.country,
        first_name: FIRST_NAMES[(club.id + index) % FIRST_NAMES.length],
        last_name: LAST_NAMES[(season_year + index) % LAST_NAMES.length],
        birthdate: generated_on - (16 + (index % 3)).years,
        position: POSITIONS[index % POSITIONS.length],
        preferred_foot: :right,
        current_ability:,
        potential_ability:,
        reputation: [ club.reputation - 2, 1 ].max,
        morale: 60,
        condition: 100,
        youth_academy_player: true,
        academy_graduate: false,
        **attribute_defaults(current_ability)
      )
    end

    def base_ability
      [ (club.reputation + club.academy_quality) / 3, 1 ].max
    end

    def potential_gap(index)
      club.academy_quality + club.country.reputation / 2 + (index.zero? ? 3 : index % 4)
    end

    def attribute_defaults(value)
      Athlete::ATTRIBUTES.index_with { |attribute| attribute.to_s.in?(%w[pace stamina work_rate]) ? [ value + 1, 20 ].min : value }
    end

    def publish_news!(intake)
      NewsPublisher.call(
        category: :youth,
        title: "#{club.name} announce #{season_year} youth intake",
        body: "#{intake.athletes.count} prospects joined the academy.",
        occurred_on: generated_on,
        club:
      )
    end
end
