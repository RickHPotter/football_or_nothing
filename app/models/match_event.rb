class MatchEvent < ApplicationRecord
  enum :event_type, {
    goal: 0,
    major_chance: 1,
    yellow_card: 2,
    red_card: 3,
    injury: 4,
    substitution: 5
  }

  belongs_to :fixture
  belongs_to :club
  belongs_to :athlete

  validates :minute, numericality: { only_integer: true, in: 1..120 }
  validates :description, presence: true
end
