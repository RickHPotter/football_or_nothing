class YouthIntake < ApplicationRecord
  belongs_to :club
  has_many :athletes, dependent: :nullify

  validates :season_year, :generated_on, presence: true
  validates :season_year, uniqueness: { scope: :club_id }
end
