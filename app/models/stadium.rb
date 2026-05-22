class Stadium < ApplicationRecord
  enum :ownership, { club_owned: 0, rented: 1, municipal: 2, shared: 3 }

  belongs_to :country
  belongs_to :club
  has_many :fixtures, dependent: :restrict_with_exception

  validates :name, :city, presence: true
  validates :name, uniqueness: { scope: :country_id }
  validates :capacity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :pitch_quality, numericality: { only_integer: true, in: 1..20 }
end
