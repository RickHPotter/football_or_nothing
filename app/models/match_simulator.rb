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
      create_match_texture_events
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

    def create_match_texture_events
      create_major_chance_events(fixture.home_club, 101)
      create_major_chance_events(fixture.away_club, 131)
      create_card_events(fixture.home_club, 163)
      create_card_events(fixture.away_club, 191)
      create_injury_event(fixture.home_club, 211)
      create_injury_event(fixture.away_club, 227)
      create_substitution_event(fixture.home_club, 241)
      create_substitution_event(fixture.away_club, 257)
      apply_availability_events
    end

    def create_major_chance_events(club, salt)
      players = attacking_options(club)
      return if players.empty?

      chance_count = 1 + (seeded_value(salt) % 2)
      chance_count.times do |index|
        player = players[(seeded_value(salt + index) + index) % players.length]

        fixture.match_events.create!(
          club:,
          athlete: player,
          minute: event_minute(salt, index, 10, 84),
          event_type: :major_chance,
          description: "#{player.first_name} #{player.last_name} created a clear chance for #{club.name}."
        )
      end
    end

    def create_card_events(club, salt)
      players = defensive_options(club)
      return if players.empty?

      yellow_count = seeded_value(salt) % 3
      yellow_count.times do |index|
        player = players[(seeded_value(salt + index) + index) % players.length]

        fixture.match_events.create!(
          club:,
          athlete: player,
          minute: event_minute(salt, index, 18, 88),
          event_type: :yellow_card,
          description: "#{player.first_name} #{player.last_name} was booked for #{club.name}."
        )
      end

      return unless seeded_value(salt + 19) >= 18

      player = players[seeded_value(salt + 23) % players.length]
      fixture.match_events.create!(
        club:,
        athlete: player,
        minute: event_minute(salt + 23, 0, 35, 89),
        event_type: :red_card,
        description: "#{player.first_name} #{player.last_name} was sent off for #{club.name}."
      )
    end

    def create_injury_event(club, salt)
      players = athletes_in_match(club)
      return if players.empty? || seeded_value(salt) < 14

      player = players[seeded_value(salt + 7) % players.length]
      fixture.match_events.create!(
        club:,
        athlete: player,
        minute: event_minute(salt, 0, 20, 86),
        event_type: :injury,
        description: "#{player.first_name} #{player.last_name} picked up an injury for #{club.name}."
      )
    end

    def create_substitution_event(club, salt)
      lineup = fixture.lineup_for(club)
      bench_player = lineup&.lineup_athletes&.bench&.includes(:athlete)&.order(:lineup_slot)&.first&.athlete
      return unless bench_player

      fixture.match_events.create!(
        club:,
        athlete: bench_player,
        minute: event_minute(salt, 0, 58, 78),
        event_type: :substitution,
        description: "#{bench_player.first_name} #{bench_player.last_name} came on for #{club.name}."
      )
    end

    def apply_availability_events
      fixture.match_events.injury.includes(:athlete).find_each do |event|
        event.athlete.update!(
          status: :injured,
          injury_until: fixture.scheduled_on + 14.days,
          condition: [ event.athlete.condition - 20, 0 ].max
        )
      end

      fixture.match_events.red_card.includes(:athlete).find_each do |event|
        event.athlete.update!(suspended_until: fixture.scheduled_on + 7.days)
      end
    end

    def update_athlete_stats(club)
      athletes_in_match(club).each do |athlete|
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

      fixture.match_events.where(club:).where(event_type: %i[yellow_card red_card injury]).includes(:athlete).find_each do |event|
        stat = athlete_stat_for(club, event.athlete)
        stat.yellow_cards += 1 if event.yellow_card?
        stat.red_cards += 1 if event.red_card?
        stat.injuries += 1 if event.injury?
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
      athletes = athletes_in_match(club).sort_by { |athlete| [ -Athlete.positions[athlete.position], -athlete.current_ability, athlete.id ] }
      athletes.presence || club.athletes.order(current_ability: :desc, id: :asc).to_a
    end

    def attacking_options(club)
      athletes_in_match(club).sort_by { |athlete| [ -athlete.finishing, -athlete.passing, -athlete.current_ability, athlete.id ] }
    end

    def defensive_options(club)
      athletes_in_match(club).sort_by { |athlete| [ -athlete.tackling, -athlete.marking, -athlete.current_ability, athlete.id ] }
    end

    def athletes_in_match(club)
      fixture.ensure_match_setup!
      lineup = fixture.lineup_for(club)
      lineup_athletes = lineup&.lineup_athletes&.starters&.includes(:athlete)&.order(:lineup_slot)
      athletes = lineup_athletes&.map(&:athlete).to_a
      athletes.presence || club.current_athletes.order(position: :asc, current_ability: :desc, id: :asc).limit(11).to_a
    end

    def goal_minute(index, goal_count, salt)
      spread = 80 / (goal_count + 1)
      [ 5 + ((index + 1) * spread) + (seeded_value(salt + 90 + index) % 7), 90 ].min
    end

    def event_minute(salt, index, minimum, maximum)
      minimum + ((seeded_value(salt + index) + (index * 11)) % (maximum - minimum + 1))
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
