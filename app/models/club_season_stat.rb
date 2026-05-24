# frozen_string_literal: true

class ClubSeasonStat < ApplicationRecord
  belongs_to :club
  belongs_to :tournament_edition

  validates :club_id, uniqueness: { scope: :tournament_edition_id }
  validates :played, :wins, :draws, :losses, :goals_for, :goals_against, :points,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def goal_difference
    goals_for - goals_against
  end
end
