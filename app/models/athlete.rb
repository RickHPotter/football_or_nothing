class Athlete < ApplicationRecord
  ATTRIBUTES = %i[
    finishing long_shots passing crossing dribbling technique first_touch
    tackling marking positioning heading pace acceleration stamina strength
    jumping decisions composure teamwork work_rate
  ].freeze

  enum :position, {
    goalkeeper: 0,
    center_back: 1,
    full_back: 2,
    defensive_midfielder: 3,
    central_midfielder: 4,
    attacking_midfielder: 5,
    winger: 6,
    striker: 7
  }
  enum :preferred_foot, { right: 0, left: 1, either: 2 }
  enum :status, { active: 0, injured: 1, retired: 2 }

  belongs_to :country
  has_many :athlete_contracts, dependent: :destroy
  has_many :clubs, through: :athlete_contracts
  has_one :current_athlete_contract, -> { where(current: true) }, class_name: "AthleteContract", inverse_of: :athlete
  has_one :current_club, through: :current_athlete_contract, source: :club
  has_many :match_events, dependent: :restrict_with_exception
  has_many :athlete_season_stats, dependent: :destroy
  has_many :transfers, dependent: :restrict_with_exception
  has_many :transfer_offers, dependent: :restrict_with_exception

  validates :first_name, :last_name, presence: true
  validates :current_ability, :potential_ability, :reputation,
    numericality: { only_integer: true, in: 1..20 }
  validates :morale, numericality: { only_integer: true, in: 0..100 }
  validates :condition, numericality: { only_integer: true, in: 0..100 }
  validates(*ATTRIBUTES, numericality: { only_integer: true, in: 1..20 })

  def available_on?(date)
    active? && availability_date_clear?(injury_until, date) && availability_date_clear?(suspended_until, date)
  end

  private
    def availability_date_clear?(blocked_until, date)
      blocked_until.nil? || blocked_until < date
    end
end
