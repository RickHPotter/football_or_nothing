# frozen_string_literal: true

class Lineup < ApplicationRecord
  enum :mentality, { defensive: 0, balanced: 1, attacking: 2 }
  enum :status, { draft: 0, confirmed: 1 }

  belongs_to :fixture
  belongs_to :club
  has_many :lineup_athletes, dependent: :destroy
  has_many :athletes, through: :lineup_athletes

  validates :formation, presence: true
  validates :club_id, uniqueness: { scope: :fixture_id }
  validate :club_must_play_fixture

  scope :for_fixture_order, -> { joins(:club).order("clubs.name ASC") }

  def starters
    lineup_athletes.starters.includes(:athlete).order(:lineup_slot)
  end

  def bench
    lineup_athletes.bench.includes(:athlete).order(:lineup_slot)
  end

  def reserves
    lineup_athletes.reserves.includes(:athlete).order(:lineup_slot)
  end

  private

  def club_must_play_fixture
    errors.add(:club, "must play fixture") if fixture && !fixture.involves?(club)
  end
end
