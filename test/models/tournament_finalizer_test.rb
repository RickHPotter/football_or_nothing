require "test_helper"

class TournamentFinalizerTest < ActiveSupport::TestCase
  setup do
    @edition = tournament_editions(:one)
    @edition.update!(status: :in_progress, champion: nil)
    @edition.trophies.destroy_all
    @edition.club_season_stats.destroy_all
    @edition.manager_season_stats.destroy_all
    @edition.fixtures.update_all(status: Fixture.statuses[:completed])
    tournament_participations(:one).update!(
      tournament_edition: @edition,
      club: clubs(:one),
      points: 6,
      goals_for: 4,
      goals_against: 1
    )
    TournamentParticipation.find_or_create_by!(tournament_edition: @edition, club: clubs(:two)).update!(
      points: 3,
      goals_for: 2,
      goals_against: 2
    )
    manager_contracts(:one).update!(club: clubs(:one), current: true, status: :active, role: :head_coach, end_date: nil)
  end

  test "completes edition and creates trophy for standings leader" do
    assert_difference "Trophy.count", 1 do
      assert_difference "ClubSeasonStat.count", 2 do
        assert_difference "ManagerSeasonStat.count", 1 do
          TournamentFinalizer.call(@edition)
        end
      end
    end

    assert @edition.reload.completed?
    assert_equal clubs(:one), @edition.champion
    assert_equal clubs(:one), @edition.trophies.last.club
    assert_equal managers(:one), @edition.trophies.last.manager
    assert @edition.club_season_stats.find_by!(club: clubs(:one)).champion?
    assert_equal 1, @edition.manager_season_stats.find_by!(manager: managers(:one)).trophies
  end

  test "does not duplicate season stats" do
    assert_difference "ClubSeasonStat.count", 2 do
      TournamentFinalizer.call(@edition)
    end

    assert_no_difference "ClubSeasonStat.count" do
      TournamentFinalizer.call(@edition)
    end
  end

  test "does not complete edition while fixtures remain scheduled" do
    @edition.trophies.destroy_all
    fixtures(:one).update!(status: :scheduled)

    assert_no_difference "Trophy.count" do
      TournamentFinalizer.call(@edition)
    end

    assert_not @edition.reload.completed?
  end
end
