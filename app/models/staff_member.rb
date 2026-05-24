# frozen_string_literal: true

class StaffMember < ApplicationRecord
  ATTRIBUTES = %i[
    coaching fitness scouting judging_ability judging_potential physiotherapy
    discipline motivation
  ].freeze

  enum :role, { assistant_manager: 0, coach: 1, fitness_coach: 2, scout: 3, physio: 4 }
  enum :status, { active: 0, retired: 1 }

  belongs_to :country
  has_many :staff_contracts, dependent: :destroy
  has_one :current_staff_contract, -> { where(current: true) }, class_name: "StaffContract", inverse_of: :staff_member
  has_one :current_club, through: :current_staff_contract, source: :club

  validates :first_name, :last_name, presence: true
  validates :reputation, numericality: { only_integer: true, in: 1..20 }
  validates(*ATTRIBUTES, numericality: { only_integer: true, in: 1..20 })

  def full_name
    "#{first_name} #{last_name}"
  end
end
