class AthleteSeasonStat < ApplicationRecord
  belongs_to :athlete
  belongs_to :club
  belongs_to :tournament_edition

  validates :athlete_id, uniqueness: { scope: %i[club_id tournament_edition_id] }
  validates :appearances, :goals, :assists, :minutes_played,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :average_rating, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end
