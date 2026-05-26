# frozen_string_literal: true

class MatchdayEvent < ApplicationRecord
  enum :event_type, MatchEvent.event_types

  belongs_to :matchday_session
  belongs_to :fixture
  belongs_to :club
  belongs_to :athlete

  scope :pending, -> { where(applied_at: nil) }
  scope :due, ->(minute) { pending.where(minute: ..minute).order(:minute, :id) }

  validates :minute, numericality: { only_integer: true, in: 1..90 }
  validates :description, presence: true
end
