class MatchSimulator
  def self.call(...)
    new(...).call
  end

  def initialize(fixture)
    @fixture = fixture
  end

  def call
    return fixture if fixture.completed?

    Fixture.transaction do
      home_goals, away_goals = score
      fixture.match_events.destroy_all
      fixture.update!(
        home_goals:,
        away_goals:,
        status: :completed
      )
      create_goal_events(fixture.home_club, home_goals, 11)
      create_goal_events(fixture.away_club, away_goals, 47)
      update_athlete_stats(fixture.home_club)
      update_athlete_stats(fixture.away_club)
      update_standings(home_goals, away_goals)
      fixture.tournament_edition.in_progress! if fixture.tournament_edition.scheduled?
      TournamentFinalizer.call(fixture.tournament_edition)
    end

    fixture
  end

  private
    attr_reader :fixture

    def score
      home_strength = club_strength(fixture.home_club) + 2
      away_strength = club_strength(fixture.away_club)

      [
        goals_for(home_strength, away_strength, 17),
        goals_for(away_strength, home_strength, 53)
      ]
    end

    def club_strength(club)
      player_average = club.current_athletes.average(:current_ability).to_f
      player_average + club.reputation
    end

    def goals_for(attacking_strength, defensive_strength, salt)
      differential = attacking_strength - defensive_strength
      base = differential >= 0 ? 1 : 0
      chance = seeded_value(salt)
      bonus = case chance + differential
      when 18.. then 3
      when 12...18 then 2
      when 6...12 then 1
      else 0
      end

      [ base + bonus, 6 ].min
    end

    def seeded_value(salt)
      ((fixture.id.to_i * 31) + (fixture.home_club_id * 17) + (fixture.away_club_id * 13) + salt) % 20
    end

    def update_standings(home_goals, away_goals)
      home_participation = participation_for(fixture.home_club)
      away_participation = participation_for(fixture.away_club)

      apply_result(home_participation, home_goals, away_goals)
      apply_result(away_participation, away_goals, home_goals)
    end

    def create_goal_events(club, goal_count, salt)
      scorers = scoring_options(club)
      return if scorers.empty?

      goal_count.times do |index|
        scorer = scorers[(seeded_value(salt + index) + index) % scorers.length]
        minute = goal_minute(index, goal_count, salt)

        fixture.match_events.create!(
          club:,
          athlete: scorer,
          minute:,
          event_type: :goal,
          description: "#{scorer.first_name} #{scorer.last_name} scored for #{club.name}."
        )
      end
    end

    def update_athlete_stats(club)
      club.current_athletes.find_each do |athlete|
        stat = athlete_stat_for(club, athlete)
        stat.appearances += 1
        stat.minutes_played += 90
        stat.save!
      end

      fixture.match_events.goal.where(club:).includes(:athlete).find_each do |event|
        stat = athlete_stat_for(club, event.athlete)
        stat.goals += 1
        stat.save!
      end
    end

    def athlete_stat_for(club, athlete)
      AthleteSeasonStat.find_or_create_by!(
        athlete:,
        club:,
        tournament_edition: fixture.tournament_edition
      )
    end

    def scoring_options(club)
      athletes = club.current_athletes.order(position: :desc, current_ability: :desc, id: :asc).to_a
      athletes.presence || club.athletes.order(current_ability: :desc, id: :asc).to_a
    end

    def goal_minute(index, goal_count, salt)
      spread = 80 / (goal_count + 1)
      [ 5 + ((index + 1) * spread) + (seeded_value(salt + 90 + index) % 7), 90 ].min
    end

    def participation_for(club)
      fixture.tournament_edition.tournament_participations.find_or_create_by!(club:)
    end

    def apply_result(participation, goals_for, goals_against)
      participation.played += 1
      participation.goals_for += goals_for
      participation.goals_against += goals_against

      if goals_for > goals_against
        participation.wins += 1
        participation.points += 3
      elsif goals_for == goals_against
        participation.draws += 1
        participation.points += 1
      else
        participation.losses += 1
      end

      participation.save!
    end
end
