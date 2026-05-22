class MatchEvent < ApplicationRecord
  enum :event_type, { goal: 0 }

  belongs_to :fixture
  belongs_to :club
  belongs_to :athlete

  validates :minute, numericality: { only_integer: true, in: 1..120 }
  validates :description, presence: true
end
