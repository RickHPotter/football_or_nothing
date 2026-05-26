# frozen_string_literal: true

class MatchdaySession < ApplicationRecord
  enum :status, { not_started: 0, running: 1, paused: 2, completed: 3 }
  enum :period, { pre_match: 0, first_half: 1, half_time: 2, second_half: 3, full_time: 4 }

  belongs_to :career
  belongs_to :tournament_edition
  belongs_to :focused_fixture, class_name: "Fixture", optional: true

  validates :scheduled_on, :round, presence: true
  validates :minute, numericality: { only_integer: true, in: 0..90 }
  validates :elapsed_seconds, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :total_duration_seconds, numericality: { only_integer: true, greater_than: 0 }
  validates :round, uniqueness: { scope: %i[career_id tournament_edition_id scheduled_on] }
  validate :focused_fixture_belongs_to_matchday

  def fixtures
    tournament_edition.fixtures
                      .where(scheduled_on:, round:)
                      .includes(:home_club, :away_club, :stadium)
                      .order(:kickoff_minute, :id)
  end

  def includes_fixture?(fixture)
    fixture&.tournament_edition_id == tournament_edition_id &&
      fixture.scheduled_on == scheduled_on &&
      fixture.round == round
  end

  private

  def focused_fixture_belongs_to_matchday
    return unless focused_fixture
    return if includes_fixture?(focused_fixture)

    errors.add(:focused_fixture, "must belong to the matchday")
  end
end
