class StaffHiringProcessor
  def self.call(...)
    new(...).call
  end

  def initialize(staff_member:, club:, start_date:, wage:)
    @staff_member = staff_member
    @club = club
    @start_date = start_date
    @wage = BigDecimal(wage.to_s)
  end

  def call
    validate_hiring!

    StaffContract.transaction do
      staff_member.current_staff_contract&.update!(current: false, status: :terminated, end_date: start_date - 1.day)
      club.staff_contracts.create!(
        staff_member:,
        start_date:,
        wage:,
        status: :active,
        current: true
      )
    end
  end

  private
    attr_reader :staff_member, :club, :start_date, :wage

    def validate_hiring!
      raise ActiveRecord::RecordInvalid, contract_with_error(:staff_member, "already works for this club") if staff_member.current_club == club
      raise ActiveRecord::RecordInvalid, contract_with_error(:wage, "exceeds wage budget") if club.club_finance&.available_wage_budget.to_d < wage
    end

    def contract_with_error(attribute, message)
      StaffContract.new(staff_member:, club:, start_date:, wage:).tap do |contract|
        contract.errors.add(attribute, message)
      end
    end
end
