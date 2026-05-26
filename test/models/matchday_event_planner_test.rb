# frozen_string_literal: true

require "test_helper"

class MatchdayEventPlannerTest < ActiveSupport::TestCase
  test "plans hidden events for each fixture in the session" do
    fixture = fixtures(:one)
    fixture.match_events.destroy_all
    simultaneous_fixture = create_simultaneous_fixture(fixture)
    session = MatchdaySessionStarter.call(career: careers(:one), fixture:)

    assert_difference "MatchdayEvent.count", 4 do
      MatchdayEventPlanner.call(session:)
    end

    assert_equal 0, fixture.match_events.count
    assert_equal 0, simultaneous_fixture.match_events.count
    assert_equal [ fixture.id, simultaneous_fixture.id ], session.matchday_events.distinct.order(:fixture_id).pluck(:fixture_id)
  end

  test "does not duplicate planned events" do
    session = MatchdaySessionStarter.call(career: careers(:one), fixture: fixtures(:one))
    MatchdayEventPlanner.call(session:)

    assert_no_difference "MatchdayEvent.count" do
      MatchdayEventPlanner.call(session:)
    end
  end

  private

  def create_simultaneous_fixture(fixture)
    home_club = create_club("Plan Home")
    away_club = create_club("Plan Away")
    stadium = home_club.stadiums.create!(
      country: home_club.country,
      name: "Plan Stadium",
      city: "Plan City",
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
    club = countries(:one).clubs.create!(
      name:,
      short_name: name.first(3).upcase,
      reputation: 1,
      status: :active
    )
    add_player(club)
    club
  end

  def add_player(club)
    athlete = Athlete.create!(
      country: club.country,
      first_name: "Plan",
      last_name: "Player",
      position: :striker,
      preferred_foot: :right,
      current_ability: 5,
      potential_ability: 5,
      reputation: 1,
      morale: 50,
      condition: 100,
      status: :active,
      **Athlete::ATTRIBUTES.index_with { 5 }
    )
    club.athlete_contracts.create!(
      athlete:,
      start_date: Date.new(2026, 1, 1),
      wage: 100,
      status: :active,
      current: true
    )
  end
end
