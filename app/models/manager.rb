class Manager < ApplicationRecord
  enum :status, { active: 0, unemployed: 1, retired: 2 }

  belongs_to :user
  belongs_to :career
  belongs_to :country
  has_many :manager_contracts, dependent: :destroy
  has_many :clubs, through: :manager_contracts

  validates :first_name, :last_name, presence: true
  validates :career_id, uniqueness: true
  validates :reputation, numericality: { only_integer: true, greater_than: 0 }
end
