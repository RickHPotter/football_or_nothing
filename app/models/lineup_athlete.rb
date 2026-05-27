# frozen_string_literal: true

class LineupAthlete < ApplicationRecord
  enum :position, Athlete.positions
  enum :tactical_role, {
    standard: 0,
    defend: 1,
    support: 2,
    attack: 3
  }

  belongs_to :lineup
  belongs_to :athlete

  scope :starters, -> { where(starter: true) }
  scope :bench, -> { where(starter: false, lineup_slot: LineupBuilder::BENCH_SLOT_RANGE) }
  scope :reserves, -> { where(starter: false).where(lineup_slot: LineupBuilder::RESERVE_SLOT_START..) }

  validates :lineup_slot_key, presence: true
  validates :lineup_slot, numericality: { only_integer: true, in: 1..99 }
  validates :athlete_id, uniqueness: { scope: :lineup_id }
  validates :lineup_slot, uniqueness: { scope: :lineup_id }
  validates :substituted_on_minute, :substituted_off_minute,
            numericality: { only_integer: true, in: 0..90 },
            allow_nil: true

  def lineup_slot_label
    lineup_slot_key.to_s.upcase
  end
end
