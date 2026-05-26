# frozen_string_literal: true

class MatchdayStandingMovement
  def self.call(session)
    return {} unless session&.completed?

    session.matchday_standing_snapshots.index_by(&:club_id).transform_values(&:movement)
  end
end
