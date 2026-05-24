# frozen_string_literal: true

class TransferOfferProcessor
  def self.call(...)
    new(...).call
  end

  def initialize(offer:, transfer_date:)
    @offer = offer
    @transfer_date = transfer_date
  end

  def call
    raise ActiveRecord::RecordInvalid, offer_with_error(:status, "is not pending") unless offer.pending?
    raise ActiveRecord::RecordInvalid, offer_with_error(:offered_fee, "does not meet asking price") unless offer.acceptable?

    TransferOffer.transaction do
      offer.update!(status: :accepted, decided_on: transfer_date)
      transfer = TransferProcessor.call(
        athlete: offer.athlete,
        to_club: offer.to_club,
        transfer_date:,
        fee: offer.offered_fee,
        wage: offer.offered_wage,
        transfer_type: offer.transfer_type,
        loan_ends_on: offer.loan_ends_on
      )
      offer.update!(status: :completed)
      transfer
    end
  end

  private

  attr_reader :offer, :transfer_date

  def offer_with_error(attribute, message)
    offer.tap { |record| record.errors.add(attribute, message) }
  end
end
