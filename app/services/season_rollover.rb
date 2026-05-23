class SeasonRollover
  def self.call(...)
    new(...).call
  end

  def initialize(tournament_edition)
    @tournament_edition = tournament_edition
  end

  def call
    raise ArgumentError, "Tournament edition must be completed" unless tournament_edition.completed?

    TournamentEdition.transaction do
      next_edition = find_or_create_next_edition
      ContractExpiryProcessor.call(cutoff_date: next_edition.starts_on)
      LeagueScheduler.call(next_edition, clubs_to_carry_forward) if next_edition.fixtures.none?
      next_edition
    end
  end

  private
    attr_reader :tournament_edition

    def find_or_create_next_edition
      tournament_edition.tournament.tournament_editions.find_or_create_by!(season_year: next_season_year) do |edition|
        edition.name = "#{tournament_edition.tournament.name} #{next_season_year}"
        edition.starts_on = tournament_edition.starts_on.next_year
        edition.ends_on = tournament_edition.ends_on.next_year
        edition.status = :scheduled
      end
    end

    def clubs_to_carry_forward
      tournament_edition
        .tournament_participations
        .includes(:club)
        .order(:position, :id)
        .map(&:club)
    end

    def next_season_year
      tournament_edition.season_year + 1
    end
end
