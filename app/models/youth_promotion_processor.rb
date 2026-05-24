class YouthPromotionProcessor
  def self.call(...)
    new(...).call
  end

  def initialize(athlete:, club:, promotion_date:, wage: 100)
    @athlete = athlete
    @club = club
    @promotion_date = promotion_date
    @wage = BigDecimal(wage.to_s)
  end

  def call
    validate_promotion!

    AthleteContract.transaction do
      contract = club.athlete_contracts.create!(
        athlete:,
        start_date: promotion_date,
        wage:,
        status: :active,
        current: true
      )
      athlete.update!(youth_academy_player: false, academy_graduate: true)
      publish_news!
      contract
    end
  end

  private
    attr_reader :athlete, :club, :promotion_date, :wage

    def validate_promotion!
      raise ActiveRecord::RecordInvalid, contract_with_error(:athlete, "is already under contract") if athlete.current_club
      raise ActiveRecord::RecordInvalid, contract_with_error(:athlete, "is not in this academy") unless athlete.youth_intake&.club == club
      raise ActiveRecord::RecordInvalid, contract_with_error(:wage, "exceeds wage budget") if club.club_finance&.available_wage_budget.to_d < wage
    end

    def contract_with_error(attribute, message)
      AthleteContract.new(athlete:, club:, start_date: promotion_date, wage:).tap do |contract|
        contract.errors.add(attribute, message)
      end
    end

    def publish_news!
      NewsPublisher.call(
        category: :youth,
        title: "#{athlete.first_name} #{athlete.last_name} promoted by #{club.name}",
        body: "The academy graduate joined the senior squad.",
        occurred_on: promotion_date,
        club:,
        athlete:
      )
    end
end
