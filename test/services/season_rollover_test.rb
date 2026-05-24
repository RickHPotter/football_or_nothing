# frozen_string_literal: true

require "test_helper"

class SeasonRolloverTest < ActiveSupport::TestCase
  setup do
    @edition = tournament_editions(:one)
    @edition.update!(status: :completed)
    @edition.fixtures.update_all(status: Fixture.statuses[:completed])
    TournamentParticipation.find_or_create_by!(tournament_edition: @edition, club: clubs(:one)).update!(position: 1)
    TournamentParticipation.find_or_create_by!(tournament_edition: @edition, club: clubs(:two)).update!(position: 2)
  end

  test "creates next tournament edition with fresh participations and fixtures" do
    next_edition = nil

    assert_difference "TournamentEdition.count", 1 do
      assert_difference "TournamentParticipation.count", 2 do
        assert_difference "Fixture.count", 2 do
          next_edition = SeasonRollover.call(@edition)
        end
      end
    end

    assert next_edition.scheduled?
    assert_equal 2027, next_edition.season_year
    assert_equal Date.new(2027, 2, 1), next_edition.starts_on
    assert_equal Date.new(2027, 5, 3), next_edition.ends_on
    assert_equal [ clubs(:one), clubs(:two) ].sort, next_edition.clubs.order(:id).to_a
    assert(next_edition.tournament_participations.all? { |participation| participation.played.zero? })
    assert_equal 2, next_edition.fixtures.count
  end

  test "does not duplicate next season" do
    next_edition = SeasonRollover.call(@edition)

    assert_no_difference [ "TournamentEdition.count", "TournamentParticipation.count", "Fixture.count" ] do
      assert_equal next_edition, SeasonRollover.call(@edition)
    end
  end

  test "rejects unfinished tournament edition" do
    @edition.in_progress!

    assert_raises ArgumentError do
      SeasonRollover.call(@edition)
    end
  end

  test "expires contracts before next season starts" do
    athlete_contracts(:one).update!(club: clubs(:one), current: true, status: :active, end_date: Date.new(2026, 12, 31))

    SeasonRollover.call(@edition)

    assert athlete_contracts(:one).reload.expired?
    assert_not athlete_contracts(:one).current?
  end
end
