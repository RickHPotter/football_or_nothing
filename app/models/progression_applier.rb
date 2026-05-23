class ProgressionApplier
  def self.call(...)
    new(...).call
  end

  def initialize(tournament_edition)
    @tournament_edition = tournament_edition
  end

  def call
    apply_manager_reputation
    apply_club_reputation
    apply_athlete_progression

    tournament_edition
  end

  private
    attr_reader :tournament_edition

    def apply_manager_reputation
      tournament_edition.manager_season_stats.includes(:manager).find_each do |stat|
        next if stat.reputation_change.zero?

        manager = stat.manager
        manager.update!(reputation: bounded_rating(manager.reputation + stat.reputation_change))
      end
    end

    def apply_club_reputation
      tournament_edition.club_season_stats.includes(:club).find_each do |stat|
        change = stat.champion? ? 1 : 0
        next if change.zero?

        stat.club.update!(reputation: bounded_rating(stat.club.reputation + change))
      end
    end

    def apply_athlete_progression
      tournament_edition.club_season_stats.includes(club: :athletes).find_each do |stat|
        athletes_for(stat.club).each do |athlete|
          athlete.update!(
            current_ability: bounded_rating(athlete.current_ability + ability_change_for(athlete)),
            morale: bounded_percent(athlete.morale + morale_change_for(stat)),
            condition: bounded_percent(athlete.condition - 5)
          )
        end
      end
    end

    def athletes_for(club)
      athletes = club.current_athletes.to_a
      athletes.presence || club.athletes.to_a
    end

    def ability_change_for(athlete)
      age = age_for(athlete)
      return 1 if age <= 23 && athlete.current_ability < athlete.potential_ability
      return -1 if age >= 33

      0
    end

    def morale_change_for(stat)
      return 10 if stat.champion?
      return 3 if stat.position && stat.position <= top_half_cutoff

      -3
    end

    def top_half_cutoff
      (tournament_edition.club_season_stats.count / 2.0).ceil
    end

    def age_for(athlete)
      return 25 unless athlete.birthdate

      tournament_edition.ends_on.year - athlete.birthdate.year - (tournament_edition.ends_on.yday < athlete.birthdate.yday ? 1 : 0)
    end

    def bounded_rating(value)
      value.clamp(1, 20)
    end

    def bounded_percent(value)
      value.clamp(0, 100)
    end
end
