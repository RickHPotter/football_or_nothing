# frozen_string_literal: true

class MatchdayEventPlanner
  def self.call(...)
    new(...).call
  end

  def initialize(session:)
    @session = session
  end

  def call
    return session.matchday_events if session.matchday_events.exists?

    session.fixtures.find_each do |fixture|
      fixture.ensure_match_setup!
      plan_fixture_events(fixture)
    end

    session.matchday_events
  end

  private

  attr_reader :session

  def plan_fixture_events(fixture)
    [ fixture.home_club, fixture.away_club ].each_with_index do |club, index|
      athlete = event_athlete_for(fixture, club)
      next unless athlete

      minute = event_minute(fixture, index)
      session.matchday_events.create!(
        fixture:,
        club:,
        athlete:,
        minute:,
        event_type: :major_chance,
        description: "#{athlete.first_name} #{athlete.last_name} created a chance for #{club.name}."
      )
    end
  end

  def event_athlete_for(fixture, club)
    lineup = fixture.lineup_for(club)
    lineup&.starters&.max_by { |lineup_athlete| attacker_score(lineup_athlete.athlete) }&.athlete ||
      club.current_athletes.order(current_ability: :desc, id: :asc).first
  end

  def attacker_score(athlete)
    athlete.finishing + athlete.passing + athlete.dribbling + athlete.current_ability
  end

  def event_minute(fixture, index)
    12 + (((fixture.id * 17) + (index * 29)) % 68)
  end
end
