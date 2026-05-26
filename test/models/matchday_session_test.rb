# frozen_string_literal: true

require "test_helper"

class MatchdaySessionTest < ActiveSupport::TestCase
  test "groups fixtures by edition date and round" do
    fixture = fixtures(:one)
    simultaneous_fixture = create_simultaneous_fixture(fixture)
    session = MatchdaySession.create!(
      career: careers(:one),
      tournament_edition: fixture.tournament_edition,
      scheduled_on: fixture.scheduled_on,
      round: fixture.round,
      focused_fixture: fixture
    )

    assert_equal [ fixture.id, simultaneous_fixture.id ], session.fixtures.map(&:id)
    assert session.includes_fixture?(fixture)
    assert session.includes_fixture?(simultaneous_fixture)
    assert_not session.includes_fixture?(fixtures(:two))
  end

  test "focused fixture must belong to matchday" do
    session = MatchdaySession.new(
      career: careers(:one),
      tournament_edition: fixtures(:one).tournament_edition,
      scheduled_on: fixtures(:one).scheduled_on,
      round: fixtures(:one).round,
      focused_fixture: fixtures(:two)
    )

    assert_not session.valid?
    assert_includes session.errors[:focused_fixture], "must belong to the matchday"
  end

  private

  def create_simultaneous_fixture(fixture)
    home_club = create_club("Sim Home")
    away_club = create_club("Sim Away")
    stadium = home_club.stadiums.create!(
      country: home_club.country,
      name: "Sim Stadium",
      city: "Sim City",
      capacity: 10_000,
      pitch_quality: 10,
      ownership: :club_owned
    )

    fixture.tournament_edition.fixtures.create!(
      home_club:,
      away_club:,
      stadium:,
      scheduled_on: fixture.scheduled_on,
      kickoff_minute: fixture.kickoff_minute,
      round: fixture.round
    )
  end

  def create_club(name)
    countries(:one).clubs.create!(
      name:,
      short_name: name.first(3).upcase,
      reputation: 1,
      status: :active
    )
  end
end
