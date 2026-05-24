# frozen_string_literal: true

require "test_helper"

class FixturesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
    @career = careers(:one)
    manager_contracts(:one).update!(current: true, status: :active, role: :head_coach, end_date: nil)
    @fixture = fixtures(:one)
  end

  test "show fixture involving current club" do
    get career_fixture_path(@career, @fixture)

    assert_response :success
    assert_select "h1", /#{@fixture.home_club.name}/
    assert_select "h2", "Lineups"
    assert_select "h2", "Manager Decisions"
    assert_select "h2", "Timeline"
    assert_select "h2", "Standings"
    assert_select "button", "Simulate match"
  end

  test "start pause and resume match clock" do
    post start_career_fixture_path(@career, @fixture)

    assert_redirected_to career_fixture_path(@career, @fixture)
    assert @fixture.reload.in_progress?
    assert @fixture.match_state.running?

    post pause_career_fixture_path(@career, @fixture)

    assert @fixture.match_state.reload.paused?

    post resume_career_fixture_path(@career, @fixture)

    assert @fixture.match_state.reload.running?
  end

  test "advance clock completes match at full time" do
    post start_career_fixture_path(@career, @fixture)

    6.times { post advance_clock_career_fixture_path(@career, @fixture) }

    assert @fixture.reload.completed?
    assert @fixture.match_state.reload.full_time?
  end

  test "updates managed club tactics" do
    get career_fixture_path(@career, @fixture)

    patch tactics_career_fixture_path(@career, @fixture), params: {
      lineup: {
        formation: "4-3-3",
        mentality: "attacking"
      }
    }

    assert_redirected_to career_fixture_path(@career, @fixture)
    lineup = @fixture.reload.lineup_for(@career.manager.current_club)
    assert_equal "4-3-3", lineup.formation
    assert lineup.attacking?
  end

  test "records substitution for managed club" do
    add_squad_depth(@career.manager.current_club, 12)
    get career_fixture_path(@career, @fixture)

    lineup = @fixture.reload.lineup_for(@career.manager.current_club)
    starter = lineup.starters.first
    substitute = lineup.bench.first

    post substitute_career_fixture_path(@career, @fixture), params: {
      off_lineup_athlete_id: starter.id,
      on_lineup_athlete_id: substitute.id
    }

    assert_redirected_to career_fixture_path(@career, @fixture)
    assert_not starter.reload.starter?
    assert substitute.reload.starter?
    assert_equal 1, @fixture.match_state.reload.home_substitutions
  end

  test "simulate completes fixture" do
    @fixture.update!(status: :scheduled, home_goals: nil, away_goals: nil)
    @career.update!(current_date: "2026-01-01")

    post simulate_career_fixture_path(@career, @fixture)

    assert_redirected_to career_fixture_path(@career, @fixture)
    assert @fixture.reload.completed?
    assert @fixture.match_events.any?
    assert_equal @fixture.scheduled_on, @career.reload.current_date
  end

  test "show completed fixture links next match" do
    @fixture.update!(status: :completed, home_goals: 1, away_goals: 0)
    @fixture.match_events.create!(
      club: @fixture.home_club,
      athlete: athletes(:one),
      minute: 12,
      event_type: :goal,
      description: "Joao Pereira scored for Aurora FC."
    )
    @career.update!(current_date: @fixture.scheduled_on)

    get career_fixture_path(@career, @fixture)

    assert_response :success
    assert_select "li", /Joao Pereira scored/
    assert_select "button", "Advance to next match"
  end

  test "show rejects fixture outside current club" do
    other_club = clubs(:two)
    third_club = countries(:two).clubs.create!(
      name: "Outside FC",
      short_name: "OUT",
      reputation: 1,
      status: :active
    )
    stadium = third_club.stadiums.create!(
      country: countries(:two),
      name: "Outside Park",
      city: "Outside",
      capacity: 1,
      pitch_quality: 1,
      ownership: :club_owned
    )
    fixture = tournament_editions(:two).fixtures.create!(
      home_club: third_club,
      away_club: other_club,
      stadium:,
      scheduled_on: "2026-03-01",
      round: 2
    )

    get career_fixture_path(@career, fixture)

    assert_response :not_found
  end

  private

  def add_squad_depth(club, count)
    count.times do |index|
      athlete = Athlete.create!(
        country: club.country,
        first_name: "Depth",
        last_name: "Player #{index}",
        position: :central_midfielder,
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
end
