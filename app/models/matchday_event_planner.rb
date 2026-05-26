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
    plan_goal_events(fixture)

    [ fixture.home_club, fixture.away_club ].each_with_index do |club, index|
      athlete = event_athlete_for(fixture, club)
      next unless athlete

      minute = event_minute(fixture, index, 10, 82)
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

  def plan_goal_events(fixture)
    planned_score(fixture).each do |club, goal_count|
      goal_count.times do |index|
        athlete = goal_athlete_for(fixture, club, index)
        next unless athlete

        session.matchday_events.create!(
          fixture:,
          club:,
          athlete:,
          minute: goal_minute(fixture, club, index, goal_count),
          event_type: :goal,
          description: "#{athlete.first_name} #{athlete.last_name} scored for #{club.name}."
        )
      end
    end
  end

  def planned_score(fixture)
    home_goals = goals_for(fixture, fixture.home_club, fixture.away_club, 17) + 1
    away_goals = goals_for(fixture, fixture.away_club, fixture.home_club, 53)

    { fixture.home_club => [ home_goals, 5 ].min, fixture.away_club => [ away_goals, 5 ].min }
  end

  def goals_for(fixture, club, opponent, salt)
    differential = team_strength(fixture, club)[:attack] - team_strength(fixture, opponent)[:defense]
    chance = seeded_value(fixture, salt)

    case chance + differential
    when 18.. then 2
    when 10...18 then 1
    else 0
    end
  end

  def goal_athlete_for(fixture, club, index)
    lineup = fixture.lineup_for(club)
    options = lineup&.starters&.sort_by { |lineup_athlete| -attacker_score(lineup_athlete.athlete) }
    options&.at(index % options.length)&.athlete || event_athlete_for(fixture, club)
  end

  def event_athlete_for(fixture, club)
    lineup = fixture.lineup_for(club)
    lineup&.starters&.max_by { |lineup_athlete| attacker_score(lineup_athlete.athlete) }&.athlete ||
      club.current_athletes.order(current_ability: :desc, id: :asc).first
  end

  def attacker_score(athlete)
    athlete.finishing + athlete.passing + athlete.dribbling + athlete.current_ability
  end

  def goal_minute(fixture, club, index, goal_count)
    spread = 80 / (goal_count + 1)
    [ 5 + ((index + 1) * spread) + (seeded_value(fixture, club.id + index) % 7), 90 ].min
  end

  def event_minute(fixture, index, minimum, maximum)
    minimum + ((seeded_value(fixture, index * 29) + (index * 11)) % (maximum - minimum + 1))
  end

  def seeded_value(fixture, salt)
    ((fixture.id.to_i * 31) + (fixture.home_club_id * 17) + (fixture.away_club_id * 13) + salt) % 20
  end

  def team_strength(fixture, club)
    @team_strength ||= {}
    @team_strength[[ fixture.id, club.id ]] ||= MatchStrengthCalculator.call(fixture:, club:)
  end
end
