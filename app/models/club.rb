class Club < ApplicationRecord
  enum :status, { active: 0, inactive: 1, extinct: 2 }

  belongs_to :country
  has_one :club_finance, dependent: :destroy
  has_one :training_plan, dependent: :destroy
  has_many :stadiums, dependent: :restrict_with_exception
  has_many :athlete_contracts, dependent: :destroy
  has_many :athletes, through: :athlete_contracts
  has_many :current_athlete_contracts, -> { where(current: true) }, class_name: "AthleteContract", inverse_of: :club
  has_many :current_athletes, through: :current_athlete_contracts, source: :athlete
  has_many :manager_contracts, dependent: :destroy
  has_many :managers, through: :manager_contracts
  has_one :current_manager_contract, -> { where(current: true) }, class_name: "ManagerContract", inverse_of: :club
  has_one :current_manager, through: :current_manager_contract, source: :manager
  has_many :tournament_participations, dependent: :destroy
  has_many :tournament_editions, through: :tournament_participations
  has_many :home_fixtures, class_name: "Fixture", foreign_key: :home_club_id, dependent: :restrict_with_exception, inverse_of: :home_club
  has_many :away_fixtures, class_name: "Fixture", foreign_key: :away_club_id, dependent: :restrict_with_exception, inverse_of: :away_club
  has_many :match_events, dependent: :restrict_with_exception
  has_many :athlete_season_stats, dependent: :destroy
  has_many :trophies, dependent: :destroy
  has_many :club_season_stats, dependent: :destroy
  has_many :manager_season_stats, dependent: :destroy
  has_many :training_results, dependent: :destroy
  has_many :incoming_transfers, class_name: "Transfer", foreign_key: :to_club_id, dependent: :restrict_with_exception, inverse_of: :to_club
  has_many :outgoing_transfers, class_name: "Transfer", foreign_key: :from_club_id, dependent: :restrict_with_exception, inverse_of: :from_club
  has_many :incoming_transfer_offers, class_name: "TransferOffer", foreign_key: :to_club_id, dependent: :restrict_with_exception, inverse_of: :to_club
  has_many :outgoing_transfer_offers, class_name: "TransferOffer", foreign_key: :from_club_id, dependent: :restrict_with_exception, inverse_of: :from_club

  validates :name, :short_name, presence: true
  validates :name, uniqueness: { scope: :country_id }
  validates :reputation, numericality: { only_integer: true, greater_than: 0 }

  def current_wage_total
    current_athlete_contracts.sum(:wage)
  end

  def loaned_in_contracts
    current_athlete_contracts.where(loan: true)
  end

  def loaned_out_contracts
    athlete_contracts
      .where(current: false, loan: false)
      .where(id: AthleteContract.where(current: true, loan: true).select(:parent_athlete_contract_id))
  end
end
