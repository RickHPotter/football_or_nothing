# frozen_string_literal: true

class ExtendMatchdaySessionDuration < ActiveRecord::Migration[8.1]
  def up
    change_column_default :matchday_sessions, :total_duration_seconds, from: 20, to: 60
    MatchdaySession.where(total_duration_seconds: 20, status: MatchdaySession.statuses[:not_started]).update_all(total_duration_seconds: 60)
  end

  def down
    change_column_default :matchday_sessions, :total_duration_seconds, from: 60, to: 20
  end
end
