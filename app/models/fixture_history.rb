# frozen_string_literal: true

class FixtureHistory
  def self.call(fixture:, club:)
    new(fixture:, club:).call
  end

  def initialize(fixture:, club:)
    @fixture = fixture
    @club = club
  end

  def call
    previous_fixtures + [ fixture ] + next_fixtures
  end

  private

  attr_reader :fixture, :club

  def previous_fixtures
    club_fixtures
      .where("scheduled_on < :scheduled_on OR (scheduled_on = :scheduled_on AND id < :id)", boundary_attributes)
      .order(scheduled_on: :desc, kickoff_minute: :desc, round: :desc, id: :desc)
      .limit(2)
      .to_a
      .reverse
  end

  def next_fixtures
    club_fixtures
      .where("scheduled_on > :scheduled_on OR (scheduled_on = :scheduled_on AND id > :id)", boundary_attributes)
      .order(:scheduled_on, :kickoff_minute, :round, :id)
      .limit(2)
      .to_a
  end

  def club_fixtures
    Fixture
      .includes(:home_club, :away_club)
      .where("home_club_id = :club_id OR away_club_id = :club_id", club_id: club.id)
  end

  def boundary_attributes
    { scheduled_on: fixture.scheduled_on, id: fixture.id }
  end
end
