# frozen_string_literal: true

class LineupBoard
  ROWS = {
    "4-4-2" => [ %w[lst rst], %w[lm lcm rcm rm], %w[lb lcb rcb rb], %w[gk] ],
    "4-3-3" => [ %w[lw st rw], %w[lcm dm rcm], %w[lb lcb rcb rb], %w[gk] ],
    "4-2-3-1" => [ %w[st], %w[lw am rw], %w[ldm rdm], %w[lb lcb rcb rb], %w[gk] ]
  }.freeze

  def self.rows_for(...)
    new(...).rows
  end

  def initialize(lineup)
    @lineup = lineup
  end

  def rows
    row_keys.map do |keys|
      keys.filter_map { |key| starters_by_key[key] }
    end
  end

  private

  attr_reader :lineup

  def row_keys
    ROWS.fetch(lineup.formation, ROWS.fetch("4-4-2"))
  end

  def starters_by_key
    @starters_by_key ||= lineup.starters.index_by(&:lineup_slot_key)
  end
end
