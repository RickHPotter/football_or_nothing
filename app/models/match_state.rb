class MatchState < ApplicationRecord
  enum :clock_status, { not_started: 0, running: 1, paused: 2, full_time: 3 }

  belongs_to :fixture

  validates :minute, numericality: { only_integer: true, in: 0..90 }
  validates :home_substitutions, :away_substitutions, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }
end
