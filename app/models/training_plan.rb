# frozen_string_literal: true

class TrainingPlan < ApplicationRecord
  enum :focus, {
    balanced: 0,
    fitness: 1,
    attacking: 2,
    defending: 3,
    technical: 4,
    youth_development: 5
  }
  enum :intensity, { low: 0, normal: 1, high: 2 }

  belongs_to :club
  belongs_to :manager
  has_many :training_results, dependent: :destroy

  validates :club_id, uniqueness: true
  validates :active_from, presence: true
end
