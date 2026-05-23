class TransferProcessor
  def self.call(...)
    new(...).call
  end

  def initialize(athlete:, to_club:, transfer_date:, fee:, wage:)
    @athlete = athlete
    @to_club = to_club
    @transfer_date = transfer_date
    @fee = BigDecimal(fee.to_s)
    @wage = BigDecimal(wage.to_s)
    @current_contract = athlete.current_athlete_contract
    @from_club = @current_contract&.club
  end

  def call
    validate_transfer!

    Transfer.transaction do
      close_current_contract!
      transfer = create_transfer!
      create_new_contract!
      apply_finances!
      transfer
    end
  end

  private
    attr_reader :athlete, :to_club, :transfer_date, :fee, :wage, :current_contract, :from_club

    def validate_transfer!
      raise ActiveRecord::RecordInvalid, transfer_with_error(:to_club, "already has this athlete") if from_club == to_club
      raise ActiveRecord::RecordInvalid, transfer_with_error(:fee, "must be zero for free transfers") if free_transfer? && fee.positive?
      raise ActiveRecord::RecordInvalid, transfer_with_error(:fee, "exceeds transfer budget") if finance.transfer_budget < fee
      raise ActiveRecord::RecordInvalid, transfer_with_error(:wage, "exceeds wage budget") if projected_wage_total > finance.wage_budget
    end

    def close_current_contract!
      return unless current_contract

      current_contract.update!(
        current: false,
        status: :terminated,
        end_date: transfer_date - 1.day
      )
    end

    def create_transfer!
      Transfer.create!(
        athlete:,
        from_club:,
        to_club:,
        transfer_date:,
        fee:,
        wage:,
        transfer_type: free_transfer? ? :free_transfer : :permanent,
        status: :completed
      )
    end

    def create_new_contract!
      to_club.athlete_contracts.create!(
        athlete:,
        start_date: transfer_date,
        wage:,
        release_clause: fee.positive? ? fee * 2 : nil,
        status: :active,
        current: true
      )
    end

    def apply_finances!
      finance.update!(
        transfer_budget: finance.transfer_budget - fee,
        cash_balance: finance.cash_balance - fee
      )
      return unless from_club&.club_finance && fee.positive?

      from_finance = from_club.club_finance
      from_finance.update!(cash_balance: from_finance.cash_balance + fee)
    end

    def finance
      @finance ||= to_club.club_finance || raise(ActiveRecord::RecordInvalid, transfer_with_error(:to_club, "has no finance profile"))
    end

    def projected_wage_total
      to_club.current_athlete_contracts.sum(:wage) + wage
    end

    def free_transfer?
      from_club.nil?
    end

    def transfer_with_error(attribute, message)
      Transfer.new(athlete:, from_club:, to_club:, transfer_date:, fee:, wage:).tap do |transfer|
        transfer.errors.add(attribute, message)
      end
    end
end
