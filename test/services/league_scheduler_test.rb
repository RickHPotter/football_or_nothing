require "test_helper"

class LeagueSchedulerTest < ActiveSupport::TestCase
  test "creates participations and double round robin fixtures" do
    edition = tournament_editions(:one)
    edition.fixtures.destroy_all
    edition.tournament_participations.destroy_all
    clubs = [ clubs(:one), clubs(:two) ].sort_by(&:id)

    assert_difference "TournamentParticipation.count", 2 do
      assert_difference "Fixture.count", 2 do
        LeagueScheduler.call(edition, clubs)
      end
    end

    assert_equal clubs.sort, edition.clubs.order(:id).to_a
    assert_equal [ clubs.first.id, clubs.second.id ], edition.fixtures.order(:round).first.then { |fixture| [ fixture.home_club_id, fixture.away_club_id ] }
    assert_equal [ clubs.second.id, clubs.first.id ], edition.fixtures.order(:round).second.then { |fixture| [ fixture.home_club_id, fixture.away_club_id ] }
  end
end
