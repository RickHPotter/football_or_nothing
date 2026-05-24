class ContractExpiryProcessor
  def self.call(...)
    new(...).call
  end

  def initialize(cutoff_date:)
    @cutoff_date = cutoff_date
  end

  def call
    AthleteContract.where(current: true, loan: false).where.not(end_date: nil).where(end_date: ...cutoff_date).find_each do |contract|
      contract.update!(current: false, status: :expired)
    end
  end

  private
    attr_reader :cutoff_date
end
