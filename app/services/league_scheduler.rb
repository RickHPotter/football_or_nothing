class LeagueScheduler
  def self.call(...)
    new(...).call
  end

  def initialize(tournament_edition, clubs)
    @tournament_edition = tournament_edition
    @clubs = clubs.to_a.sort_by(&:id)
  end

  def call
    create_participations
    create_fixtures
  end

  private
    attr_reader :tournament_edition, :clubs

    def create_participations
      clubs.each do |club|
        tournament_edition.tournament_participations.find_or_create_by!(club:)
      end
    end

    def create_fixtures
      rounds.each.with_index(1) do |matches, round_number|
        scheduled_on = tournament_edition.starts_on + (round_number - 1).weeks

        matches.each do |home_club, away_club|
          tournament_edition.fixtures.find_or_create_by!(home_club:, away_club:) do |fixture|
            fixture.stadium = home_club.stadiums.order(:created_at).first
            fixture.scheduled_on = scheduled_on
            fixture.round = round_number
          end
        end
      end
    end

    def rounds
      first_leg = round_robin_pairs(clubs)
      second_leg = first_leg.map { |matches| matches.map { |home_club, away_club| [ away_club, home_club ] } }

      first_leg + second_leg
    end

    def round_robin_pairs(participants)
      rotating = participants.dup
      round_count = rotating.length - 1
      matches_per_round = rotating.length / 2

      round_count.times.map do |round_index|
        matches = matches_per_round.times.map do |match_index|
          home_club = rotating[match_index]
          away_club = rotating[-(match_index + 1)]
          round_index.even? ? [ home_club, away_club ] : [ away_club, home_club ]
        end

        rotating = [ rotating.first, rotating.last, *rotating[1...-1] ]
        matches
      end
    end
end
