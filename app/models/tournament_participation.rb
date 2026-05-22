class TournamentParticipation < ApplicationRecord
  enum :status, { active: 0, eliminated: 1, completed: 2 }

  belongs_to :tournament_edition
  belongs_to :club

  validates :club_id, uniqueness: { scope: :tournament_edition_id }
  validates :played, :wins, :draws, :losses, :goals_for, :goals_against, :points,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :prize_money, numericality: { greater_than_or_equal_to: 0 }

  def goal_difference
    goals_for - goals_against
  end
end
