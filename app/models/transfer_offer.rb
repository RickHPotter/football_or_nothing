# frozen_string_literal: true

class TransferOffer < ApplicationRecord
  enum :status, { pending: 0, accepted: 1, rejected: 2, completed: 3, expired: 4 }
  enum :transfer_type, { permanent: 0, free_transfer: 1, loan: 2 }

  belongs_to :athlete
  belongs_to :from_club, class_name: "Club", optional: true
  belongs_to :to_club, class_name: "Club"

  validates :offered_on, :expires_on, presence: true
  validates :offered_fee, :offered_wage, numericality: { greater_than_or_equal_to: 0 }
  validates :loan_ends_on, presence: true, if: :loan?
  validate :from_and_to_clubs_must_differ

  scope :recent, -> { order(created_at: :desc) }

  def acceptable?
    loan? || free_agent? || offered_fee >= asking_fee
  end

  def asking_fee
    return 0 if free_agent?

    athlete.current_athlete_contract&.release_clause || (athlete.current_ability * 50_000)
  end

  def free_agent?
    from_club.nil?
  end

  private

  def from_and_to_clubs_must_differ
    errors.add(:to_club, "must differ from selling club") if from_club_id.present? && from_club_id == to_club_id
  end
end
