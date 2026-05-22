class TournamentFinalizer
  def self.call(...)
    new(...).call
  end

  def initialize(tournament_edition)
    @tournament_edition = tournament_edition
  end

  def call
    return tournament_edition unless tournament_edition.ready_to_complete?

    winner = tournament_edition.leading_participation&.club
    return tournament_edition unless winner

    TournamentEdition.transaction do
      tournament_edition.update!(champion: winner, status: :completed)
      tournament_edition.standings.each.with_index(1) do |participation, position|
        participation.update!(position:, status: :completed)
        create_club_season_stat(participation, position, winner)
        create_manager_season_stat(participation, position, winner)
      end
      tournament_edition.trophies.find_or_create_by!(club: winner) do |trophy|
        trophy.manager = winner.current_manager
        trophy.name = tournament_edition.name
        trophy.won_on = tournament_edition.ends_on
      end
    end

    tournament_edition
  end

  private
    attr_reader :tournament_edition

    def create_club_season_stat(participation, position, winner)
      ClubSeasonStat.find_or_create_by!(
        club: participation.club,
        tournament_edition:
      ) do |stat|
        stat.position = position
        stat.played = participation.played
        stat.wins = participation.wins
        stat.draws = participation.draws
        stat.losses = participation.losses
        stat.goals_for = participation.goals_for
        stat.goals_against = participation.goals_against
        stat.points = participation.points
        stat.champion = participation.club == winner
      end
    end

    def create_manager_season_stat(participation, position, winner)
      manager = participation.club.current_manager
      return unless manager

      ManagerSeasonStat.find_or_create_by!(
        manager:,
        club: participation.club,
        tournament_edition:
      ) do |stat|
        stat.position = position
        stat.matches = participation.played
        stat.wins = participation.wins
        stat.draws = participation.draws
        stat.losses = participation.losses
        stat.trophies = participation.club == winner ? 1 : 0
        stat.reputation_change = participation.club == winner ? 2 : 0
      end
    end
end
