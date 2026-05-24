class TournamentFinalizer
  def self.call(...)
    new(...).call
  end

  def initialize(tournament_edition)
    @tournament_edition = tournament_edition
  end

  def call
    return tournament_edition if tournament_edition.completed?
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
      trophy = tournament_edition.trophies.find_or_create_by!(club: winner) do |record|
        record.manager = winner.current_manager
        record.name = tournament_edition.name
        record.won_on = tournament_edition.ends_on
      end
      publish_trophy_news!(winner, trophy)
      ProgressionApplier.call(tournament_edition)
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
        stat.reputation_change = manager_reputation_change(participation, position, winner)
      end
    end

    def manager_reputation_change(participation, position, winner)
      return 2 if participation.club == winner
      return 1 if position <= (tournament_edition.tournament_participations.count / 2.0).ceil

      0
    end

    def publish_trophy_news!(winner, trophy)
      NewsPublisher.call(
        category: :trophy,
        title: "#{winner.name} win #{tournament_edition.name}",
        body: "#{winner.name} finished top of the table and lifted the trophy.",
        occurred_on: trophy.won_on,
        club: winner,
        manager: trophy.manager,
        tournament_edition:
      )
    end
end
