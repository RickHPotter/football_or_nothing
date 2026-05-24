# frozen_string_literal: true

class MatchStat < ApplicationRecord
  belongs_to :fixture
  belongs_to :club

  validates :club_id, uniqueness: { scope: :fixture_id }
  validates :possession, numericality: { only_integer: true, in: 0..100 }
  validates :shots, :shots_on_target, :fouls, :yellow_cards, :red_cards,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
