# frozen_string_literal: true

class AthleteContract < ApplicationRecord
  enum :status, { active: 0, expired: 1, terminated: 2 }

  belongs_to :athlete
  belongs_to :club
  belongs_to :parent_athlete_contract, class_name: "AthleteContract", optional: true
  has_many :loan_contracts, class_name: "AthleteContract", foreign_key: :parent_athlete_contract_id, dependent: :restrict_with_exception,
                            inverse_of: :parent_athlete_contract

  validates :start_date, presence: true
  validates :loan_ends_on, presence: true, if: :loan?
  validates :wage, numericality: { greater_than_or_equal_to: 0 }
  validates :release_clause, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :squad_number, numericality: { only_integer: true, in: 1..99 }, allow_nil: true
  validates :external_id, uniqueness: { scope: :external_source }, allow_nil: true
end
