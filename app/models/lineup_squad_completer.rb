# frozen_string_literal: true

class LineupSquadCompleter
  def self.call(...)
    new(...).call
  end

  def initialize(lineup:, date: nil)
    @lineup = lineup
    @date = date || lineup.fixture.scheduled_on
  end

  def call
    fill_bench!
    fill_reserves!
    lineup
  end

  private

  attr_reader :lineup, :date

  def fill_bench!
    missing_count = LineupBuilder::BENCH_LIMIT - lineup.bench.count
    return unless missing_count.positive?

    available_unselected.first(missing_count).each { |athlete| add_bench_player!(athlete) }
  end

  def fill_reserves!
    available_unselected.each { |athlete| add_reserve_player!(athlete) }
  end

  def add_bench_player!(athlete)
    lineup.lineup_athletes.create!(
      athlete:,
      position: athlete.position,
      tactical_role: :standard,
      lineup_slot: next_bench_slot,
      lineup_slot_key: "sub_#{next_bench_index}",
      starter: false
    )
  end

  def add_reserve_player!(athlete)
    lineup.lineup_athletes.create!(
      athlete:,
      position: athlete.position,
      tactical_role: :standard,
      lineup_slot: next_reserve_slot,
      lineup_slot_key: "res_#{next_reserve_index}",
      starter: false
    )
  end

  def available_unselected
    roster_pool.reject { |athlete| selected_athlete_ids.include?(athlete.id) }
  end

  def selected_athlete_ids
    lineup.lineup_athletes.pluck(:athlete_id).to_set
  end

  def roster_pool
    @roster_pool ||= begin
      athletes = lineup.club.current_athletes.order(current_ability: :desc, condition: :desc, id: :asc).to_a
      athletes = lineup.club.athletes.order(current_ability: :desc, condition: :desc, id: :asc).to_a if athletes.empty?
      available = athletes.select { |athlete| athlete.available_on?(date) }
      available.presence || athletes
    end
  end

  def next_bench_slot
    used_slots = lineup.lineup_athletes.pluck(:lineup_slot).to_set
    LineupBuilder::BENCH_SLOT_RANGE.find { |slot| !used_slots.include?(slot) }
  end

  def next_bench_index
    next_bench_slot - 11
  end

  def next_reserve_slot
    [ lineup.lineup_athletes.maximum(:lineup_slot).to_i + 1, LineupBuilder::RESERVE_SLOT_START ].max
  end

  def next_reserve_index
    next_reserve_slot - LineupBuilder::RESERVE_SLOT_START + 1
  end
end
