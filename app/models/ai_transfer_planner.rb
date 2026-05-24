# frozen_string_literal: true

class AiTransferPlanner
  MAX_MOVES_PER_RUN = 1
  RECENT_MOVE_WINDOW = 90.days

  def self.call(...)
    new(...).call
  end

  def initialize(date:, excluded_clubs: [])
    @date = date
    @excluded_club_ids = Array(excluded_clubs).map { |club| club.respond_to?(:id) ? club.id : club }.compact
    @moved_athlete_ids = Set.new(recently_moved_athlete_ids)
  end

  def call
    ai_clubs.each_with_object([]) do |club, transfers|
      next unless TransferWindowPolicy.open?(club:, date:)

      MAX_MOVES_PER_RUN.times do
        transfer = make_move_for(club)
        transfers << transfer if transfer
      end
    end
  end

  private

  attr_reader :date, :excluded_club_ids, :moved_athlete_ids

  def ai_clubs
    Club.active
        .includes(:club_finance, :current_athletes)
        .where.not(id: excluded_club_ids)
        .order(reputation: :desc, id: :asc)
  end

  def make_move_for(club)
    needed_positions = SquadNeedsAnalyzer.call(club:)
    return if needed_positions.empty?

    candidate = free_agent_candidate(club, needed_positions.keys) || transfer_candidate(club, needed_positions.keys)
    return unless candidate

    fee = candidate.current_club ? asking_fee(candidate) : 0
    transfer = TransferProcessor.call(
      athlete: candidate,
      to_club: club,
      transfer_date: date,
      fee:,
      wage: proposed_wage(candidate)
    )
    moved_athlete_ids << candidate.id
    transfer
  rescue ActiveRecord::RecordInvalid
    nil
  end

  def free_agent_candidate(club, positions)
    Athlete
      .left_outer_joins(:current_athlete_contract)
      .where(athlete_contracts: { id: nil })
      .where(position: positions)
      .where.not(id: moved_athlete_ids)
      .where(reputation: ..club.reputation)
      .order(current_ability: :desc, reputation: :desc, id: :asc)
      .detect { |athlete| affordable?(club, athlete, 0) }
  end

  def transfer_candidate(club, positions)
    Athlete
      .joins(:current_athlete_contract)
      .includes(:current_athlete_contract)
      .where(position: positions)
      .where.not(id: moved_athlete_ids)
      .where.not(athlete_contracts: { club_id: club.id })
      .where(athlete_contracts: { loan: false })
      .where(reputation: ..(club.reputation + 2))
      .order(current_ability: :desc, reputation: :desc, id: :asc)
      .detect { |athlete| affordable?(club, athlete, asking_fee(athlete)) }
  end

  def affordable?(club, athlete, fee)
    finance = club.club_finance
    return false unless finance
    return false if finance.transfer_budget < fee

    finance.available_wage_budget >= proposed_wage(athlete)
  end

  def asking_fee(athlete)
    athlete.current_athlete_contract&.release_clause || (athlete.current_ability * 50_000)
  end

  def proposed_wage(athlete)
    [ athlete.current_athlete_contract&.wage || 0, athlete.current_ability * 25 ].max
  end

  def recently_moved_athlete_ids
    Transfer.where(transfer_date: (date - RECENT_MOVE_WINDOW)..date).select(:athlete_id)
  end
end
