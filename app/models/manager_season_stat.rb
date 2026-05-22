class ManagerSeasonStat < ApplicationRecord
  belongs_to :manager
  belongs_to :club
  belongs_to :tournament_edition

  validates :manager_id, uniqueness: { scope: %i[club_id tournament_edition_id] }
  validates :matches, :wins, :draws, :losses, :trophies,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :reputation_change, numericality: { only_integer: true }
end
