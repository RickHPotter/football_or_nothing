# frozen_string_literal: true

class MatchdayTimeline
  def self.call(session, limit: 4)
    return {} unless session

    session.fixtures.index_with do |fixture|
      fixture.match_events.includes(:club, :athlete).order(:minute, :id).last(limit)
    end
  end
end
