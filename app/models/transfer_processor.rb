class TransferProcessor
  def self.call(...)
    new(...).call
  end

  def initialize(athlete:, to_club:, transfer_date:, fee:, wage:, transfer_type: nil, loan_ends_on: nil)
    @athlete = athlete
    @to_club = to_club
    @transfer_date = transfer_date
    @fee = BigDecimal(fee.to_s)
    @wage = BigDecimal(wage.to_s)
    @transfer_type = transfer_type.presence&.to_s
    @loan_ends_on = loan_ends_on
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
      publish_news!(transfer)
      transfer
    end
  end

  private
    attr_reader :athlete, :to_club, :transfer_date, :fee, :wage, :transfer_type, :loan_ends_on, :current_contract, :from_club

    def validate_transfer!
      raise ActiveRecord::RecordInvalid, transfer_with_error(:to_club, "already has this athlete") if from_club == to_club
      raise ActiveRecord::RecordInvalid, transfer_with_error(:fee, "must be zero for free transfers") if free_transfer? && fee.positive?
      raise ActiveRecord::RecordInvalid, transfer_with_error(:transfer_type, "requires a parent club") if loan? && from_club.nil?
      raise ActiveRecord::RecordInvalid, transfer_with_error(:loan_ends_on, "must be present") if loan? && loan_ends_on.blank?
      raise ActiveRecord::RecordInvalid, transfer_with_error(:loan_ends_on, "must be after transfer date") if loan? && loan_end_date <= transfer_date
      raise ActiveRecord::RecordInvalid, transfer_with_error(:fee, "exceeds transfer budget") if finance.transfer_budget < fee
      raise ActiveRecord::RecordInvalid, transfer_with_error(:wage, "exceeds wage budget") if projected_wage_total > finance.wage_budget
    end

    def close_current_contract!
      return unless current_contract

      if loan?
        current_contract.update!(current: false)
      else
        current_contract.update!(
          current: false,
          status: :terminated,
          end_date: transfer_date - 1.day
        )
      end
    end

    def create_transfer!
      Transfer.create!(
        athlete:,
        from_club:,
        to_club:,
        transfer_date:,
        fee:,
        wage:,
        transfer_type: resolved_transfer_type,
        loan_ends_on: loan? ? loan_end_date : nil,
        status: :completed
      )
    end

    def create_new_contract!
      to_club.athlete_contracts.create!(
        athlete:,
        start_date: transfer_date,
        end_date: loan? ? loan_end_date : nil,
        wage:,
        release_clause: fee.positive? ? fee * 2 : nil,
        loan: loan?,
        loan_ends_on: loan? ? loan_end_date : nil,
        parent_athlete_contract: loan? ? current_contract : nil,
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
      !loan? && from_club.nil?
    end

    def loan?
      transfer_type == "loan"
    end

    def resolved_transfer_type
      return :loan if loan?

      free_transfer? ? :free_transfer : :permanent
    end

    def loan_end_date
      loan_ends_on&.to_date
    end

    def transfer_with_error(attribute, message)
      Transfer.new(athlete:, from_club:, to_club:, transfer_date:, fee:, wage:, transfer_type: resolved_transfer_type, loan_ends_on: loan_ends_on.presence).tap do |transfer|
        transfer.errors.add(attribute, message)
      end
    end

    def publish_news!(transfer)
      NewsPublisher.call(
        category: :transfer,
        title: "#{athlete.first_name} #{athlete.last_name} joins #{to_club.name}",
        body: "#{to_club.name} completed a #{transfer.transfer_type.humanize.downcase} move.",
        occurred_on: transfer_date,
        club: to_club,
        athlete:
      )
    end
end
