class AthleteContract < ApplicationRecord
  enum :status, { active: 0, expired: 1, terminated: 2 }

  belongs_to :athlete
  belongs_to :club

  validates :start_date, presence: true
  validates :wage, numericality: { greater_than_or_equal_to: 0 }
  validates :release_clause, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :squad_number, numericality: { only_integer: true, in: 1..99 }, allow_nil: true
end
