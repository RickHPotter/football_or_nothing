require "test_helper"

class MatchSimulatorTest < ActiveSupport::TestCase
  setup do
    @fixture = fixtures(:one)
    @fixture.update!(status: :scheduled, home_goals: nil, away_goals: nil)
    tournament_participations(:one).update!(
      tournament_edition: @fixture.tournament_edition,
      club: @fixture.home_club,
      played: 0,
      wins: 0,
      draws: 0,
      losses: 0,
      goals_for: 0,
      goals_against: 0,
      points: 0
    )
    TournamentParticipation.find_or_create_by!(
      tournament_edition: @fixture.tournament_edition,
      club: @fixture.away_club
    ).update!(
      played: 0,
      wins: 0,
      draws: 0,
      losses: 0,
      goals_for: 0,
      goals_against: 0,
      points: 0
    )
  end

  test "simulates fixture and updates standings" do
    MatchSimulator.call(@fixture)

    assert @fixture.reload.completed?
    assert_not_nil @fixture.home_goals
    assert_not_nil @fixture.away_goals
    assert_equal @fixture.home_goals + @fixture.away_goals, @fixture.match_events.count
    assert_equal 1, participation_for(@fixture.home_club).played
    assert_equal 1, participation_for(@fixture.away_club).played
    assert @fixture.home_club.current_athletes.all? { |athlete| athlete.athlete_season_stats.exists?(club: @fixture.home_club, tournament_edition: @fixture.tournament_edition, appearances: 1) }
  end

  test "increments scorer goals in athlete season stats" do
    MatchSimulator.call(@fixture)

    @fixture.match_events.goal.find_each do |event|
      stat = event.athlete.athlete_season_stats.find_by!(club: event.club, tournament_edition: @fixture.tournament_edition)

      assert_operator stat.goals, :>=, 1
    end
  end

  test "does not simulate completed fixture twice" do
    MatchSimulator.call(@fixture)
    home_points = participation_for(@fixture.home_club).points
    away_points = participation_for(@fixture.away_club).points
    home_played = participation_for(@fixture.home_club).played

    MatchSimulator.call(@fixture)

    assert_equal home_points, participation_for(@fixture.home_club).points
    assert_equal away_points, participation_for(@fixture.away_club).points
    assert_equal home_played, participation_for(@fixture.home_club).played
  end

  test "finalizes tournament after last fixture" do
    @fixture.tournament_edition.trophies.destroy_all
    @fixture.tournament_edition.fixtures.where.not(id: @fixture.id).update_all(status: Fixture.statuses[:completed])

    assert_difference "Trophy.count", 1 do
      MatchSimulator.call(@fixture)
    end

    assert @fixture.tournament_edition.reload.completed?
    assert_equal @fixture.tournament_edition.leading_participation.club, @fixture.tournament_edition.champion
  end

  private
    def participation_for(club)
      @fixture.tournament_edition.tournament_participations.find_by!(club:)
    end
end
