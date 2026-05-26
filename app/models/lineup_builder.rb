# frozen_string_literal: true

class LineupBuilder
  BENCH_LIMIT = 7
  BENCH_GROUPS = [
    %i[goalkeeper],
    %i[center_back full_back],
    %i[defensive_midfielder central_midfielder attacking_midfielder],
    %i[winger striker]
  ].freeze

  def self.call(...)
    new(...).call
  end

  def initialize(lineup:, date: nil)
    @lineup = lineup
    @date = date || lineup.fixture.scheduled_on
  end

  def call
    lineup.lineup_athletes.destroy_all
    selected = []
    build_starters(selected)
    build_bench(selected)
    lineup
  end

  private

  attr_reader :lineup, :date

  def build_starters(selected)
    LineupTemplate.for(lineup.formation).each_with_index do |slot, index|
      athlete = pick_for_slot(slot, selected)
      next unless athlete

      selected << athlete
      lineup.lineup_athletes.create!(
        athlete:,
        position: slot.position,
        tactical_role: :standard,
        lineup_slot: index + 1,
        starter: true
      )
    end
  end

  def build_bench(selected)
    bench = []
    BENCH_GROUPS.each do |positions|
      athlete = best_available(available_pool - selected - bench, positions)
      bench << athlete if athlete
    end

    remaining = available_pool - selected - bench
    remaining = remaining.reject(&:goalkeeper?) if bench.any?(&:goalkeeper?)
    bench.concat(remaining.first(BENCH_LIMIT - bench.length))

    bench.first(BENCH_LIMIT).each_with_index do |athlete, index|
      lineup.lineup_athletes.create!(
        athlete:,
        position: athlete.position,
        tactical_role: :standard,
        lineup_slot: 12 + index,
        starter: false
      )
    end
  end

  def pick_for_slot(slot, selected)
    pool = available_pool - selected
    best_available(pool, slot.preferred_positions) ||
      best_available(pool, slot.fallback_positions) ||
      best_available(pool.reject(&:goalkeeper?))
  end

  def best_available(pool, positions = nil)
    candidates = positions.present? ? pool.select { |athlete| positions.include?(athlete.position.to_sym) } : pool
    candidates.max_by { |athlete| athlete_score(athlete) }
  end

  def available_pool
    @available_pool ||= begin
      athletes = lineup.club.current_athletes.order(current_ability: :desc, condition: :desc, id: :asc).to_a
      athletes = lineup.club.athletes.order(current_ability: :desc, condition: :desc, id: :asc).to_a if athletes.empty?
      available = athletes.select { |athlete| athlete.available_on?(date) }
      available.presence || athletes
    end
  end

  def athlete_score(athlete)
    (athlete.current_ability * 10) + athlete.condition + athlete.reputation
  end
end
