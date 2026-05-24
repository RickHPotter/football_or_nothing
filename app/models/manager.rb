class Manager < ApplicationRecord
  enum :status, { active: 0, unemployed: 1, retired: 2 }

  belongs_to :user
  belongs_to :career
  belongs_to :country
  has_many :manager_contracts, dependent: :destroy
  has_many :training_plans, dependent: :destroy
  has_many :clubs, through: :manager_contracts
  has_one :current_manager_contract, -> { where(current: true) }, class_name: "ManagerContract", inverse_of: :manager
  has_one :current_club, through: :current_manager_contract, source: :club
  has_many :trophies, dependent: :nullify
  has_many :manager_season_stats, dependent: :destroy

  validates :first_name, :last_name, presence: true
  validates :career_id, uniqueness: true
  validates :reputation, numericality: { only_integer: true, greater_than: 0 }

  def job_reputation_ceiling
    reputation + 5
  end

  def eligible_for_club?(club)
    club.reputation <= job_reputation_ceiling
  end
end
