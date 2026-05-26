# frozen_string_literal: true

class MatchdayStandingSnapshot < ApplicationRecord
  belongs_to :matchday_session
  belongs_to :tournament_participation
  belongs_to :club

  validates :tournament_participation_id, uniqueness: { scope: :matchday_session_id }

  def movement
    return 0 unless position_before && position_after

    position_before - position_after
  end
end
