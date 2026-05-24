# frozen_string_literal: true

class ScoutReport < ApplicationRecord
  belongs_to :club
  belongs_to :athlete
  belongs_to :scouting_assignment, optional: true

  validates :athlete_id, uniqueness: { scope: :club_id }
  validates :created_on, presence: true
  validates :observed_current_ability, :observed_potential_ability,
            numericality: { only_integer: true, in: 1..20 }
  validates :confidence, numericality: { only_integer: true, in: 0..100 }
end
