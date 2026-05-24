class Country < ApplicationRecord
  enum :status, { active: 0, inactive: 1 }

  has_many :clubs, dependent: :restrict_with_exception
  has_many :stadiums, dependent: :restrict_with_exception
  has_many :athletes, dependent: :restrict_with_exception
  has_many :managers, dependent: :restrict_with_exception
  has_many :staff_members, dependent: :restrict_with_exception
  has_many :tournaments, dependent: :restrict_with_exception
  has_many :scouting_assignments, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true
  validates :reputation, numericality: { only_integer: true, greater_than: 0 }
end
