class Club < ApplicationRecord
  enum :status, { active: 0, inactive: 1, extinct: 2 }

  belongs_to :country
  has_one :club_finance, dependent: :destroy
  has_many :stadiums, dependent: :restrict_with_exception
  has_many :athlete_contracts, dependent: :destroy
  has_many :athletes, through: :athlete_contracts
  has_many :manager_contracts, dependent: :destroy
  has_many :managers, through: :manager_contracts

  validates :name, :short_name, presence: true
  validates :name, uniqueness: { scope: :country_id }
  validates :reputation, numericality: { only_integer: true, greater_than: 0 }
end
