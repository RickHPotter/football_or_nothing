# frozen_string_literal: true

class Transfer < ApplicationRecord
  enum :transfer_type, { permanent: 0, free_transfer: 1, loan: 2 }
  enum :status, { completed: 0, failed: 1 }

  belongs_to :athlete
  belongs_to :from_club, class_name: "Club", optional: true
  belongs_to :to_club, class_name: "Club"

  validates :transfer_date, presence: true
  validates :fee, :wage, numericality: { greater_than_or_equal_to: 0 }
  validates :loan_ends_on, presence: true, if: :loan?
  validate :from_and_to_clubs_must_differ

  private

  def from_and_to_clubs_must_differ
    errors.add(:to_club, "must differ from selling club") if from_club_id.present? && from_club_id == to_club_id
  end
end
