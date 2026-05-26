# frozen_string_literal: true

require "test_helper"

class CareersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      email_address: "career@example.com",
      password: "password",
      password_confirmation: "password"
    )
    sign_in_as(@user)
  end

  test "new" do
    get new_career_path

    assert_response :success
  end

  test "create with valid attributes" do
    assert_difference [ "Career.count", "Manager.count" ], 1 do
      post careers_path, params: {
        career: {
          name: "My First Career",
          current_date: "2026-01-01"
        },
        manager: {
          first_name: "Alex",
          last_name: "Lovelace",
          birthdate: "1990-01-01",
          country_id: countries(:one).id
        }
      }
    end

    assert_redirected_to career_path(Career.order(:created_at).last)
    assert Career.order(:created_at).last.manager.unemployed?
  end

  test "create with invalid attributes" do
    assert_no_difference [ "Career.count", "Manager.count" ] do
      post careers_path, params: {
        career: {
          name: "",
          current_date: "2026-01-01"
        },
        manager: {
          first_name: "",
          last_name: "",
          country_id: countries(:one).id
        }
      }
    end

    assert_response :unprocessable_content
  end

  test "show offers jobs to unemployed manager" do
    sign_out
    sign_in_as(users(:one))
    regional_tournament = countries(:one).tournaments.create!(
      name: "Campeonato BR Division 1",
      short_name: "BRD",
      scope: :domestic,
      format: :league,
      status: :active
    )
    regional_edition = regional_tournament.tournament_editions.create!(
      season_year: 2027,
      name: "Campeonato BR Division 1 2027",
      starts_on: Date.new(2027, 1, 1),
      ends_on: Date.new(2027, 5, 1),
      status: :scheduled
    )
    regional_edition.tournament_participations.create!(club: clubs(:one))

    get career_path(careers(:one))

    assert_response :success
    assert_select "h2", "Available jobs"
    assert_select "select[name='country_id'] option[selected='selected']", countries(:one).name
    assert_select "select[name='division_id'] option[selected='selected']", tournament_editions(:one).name
    assert_select "th", "Division"
    assert_select "td", /#{tournaments(:one).name}/
    assert_select "td", text: /#{regional_tournament.name}/, count: 0
    assert_select "button", "Take job"
  end

  test "show filters available jobs by selected country" do
    sign_out
    sign_in_as(users(:one))

    get career_path(careers(:one), country_id: countries(:two).id)

    assert_response :success
    assert_select "select[name='country_id'] option[selected='selected']", countries(:two).name
    assert_select "select[name='division_id'] option[selected='selected']", tournament_editions(:two).name
    assert_select "td", text: clubs(:two).name
    assert_select "td", text: clubs(:one).name, count: 0
  end

  test "show filters available jobs by selected division" do
    sign_out
    sign_in_as(users(:one))
    tournament = countries(:one).tournaments.create!(
      name: "Brasilia Second Division",
      short_name: "BSD",
      scope: :domestic,
      format: :league,
      status: :active
    )
    edition = tournament.tournament_editions.create!(
      season_year: 2026,
      name: "Brasilia Second Division 2026",
      starts_on: Date.new(2026, 2, 1),
      ends_on: Date.new(2026, 5, 1),
      status: :scheduled
    )
    edition.tournament_participations.create!(club: clubs(:one))

    get career_path(careers(:one), country_id: countries(:one).id, division_id: edition.id)

    assert_response :success
    assert_select "select[name='division_id'] option[selected='selected']", edition.name
    assert_select "td", text: /#{tournament.name}/
    assert_select "button", "Take job"
  end

  test "show links current club when manager has job" do
    sign_out
    sign_in_as(users(:one))
    manager_contracts(:one).update!(current: true, status: :active, role: :head_coach, end_date: nil)

    get career_path(careers(:one))

    assert_response :success
    assert_select "a", "Open club dashboard"
    assert_select "h2", "Trophies"
    assert_select "h2", "Manager seasons"
    assert_select "p", /Total:/
  end

  test "show displays next fixture when manager has job" do
    sign_out
    sign_in_as(users(:one))
    manager_contracts(:one).update!(current: true, status: :active, role: :head_coach, end_date: nil)
    careers(:one).update!(current_date: "2026-01-01")

    get career_path(careers(:one))

    assert_response :success
    assert_select "h2", "Next fixture"
    assert_select "button", "Advance to match day"
  end

  test "show offers season rollover when completed season has no upcoming fixture" do
    sign_out
    sign_in_as(users(:one))
    manager_contracts(:one).update!(current: true, status: :active, role: :head_coach, end_date: nil)
    careers(:one).update!(current_date: "2026-12-31")
    tournament_editions(:one).update!(status: :completed)
    TournamentParticipation.find_or_create_by!(tournament_edition: tournament_editions(:one), club: clubs(:one)).update!(position: 1)
    TournamentParticipation.find_or_create_by!(tournament_edition: tournament_editions(:one), club: clubs(:two)).update!(position: 2)

    get career_path(careers(:one))

    assert_response :success
    assert_select "button", "Start next season"
  end

  test "advance moves current date to next fixture" do
    sign_out
    sign_in_as(users(:one))
    manager_contracts(:one).update!(current: true, status: :active, role: :head_coach, end_date: nil)
    careers(:one).update!(current_date: "2026-01-01")

    post advance_career_path(careers(:one))

    assert_redirected_to career_fixture_path(careers(:one), fixtures(:one))
    assert_nil flash[:notice]
    assert_equal fixtures(:one).scheduled_on, careers(:one).reload.current_date
  end

  test "advance handles no upcoming fixture" do
    sign_out
    sign_in_as(users(:one))
    manager_contracts(:one).update!(current: true, status: :active, role: :head_coach, end_date: nil)
    careers(:one).update!(current_date: "2027-01-01")

    post advance_career_path(careers(:one))

    assert_redirected_to career_path(careers(:one))
    assert_equal Date.new(2027, 1, 1), careers(:one).reload.current_date
  end

  test "rollover starts next season" do
    sign_out
    sign_in_as(users(:one))
    manager_contracts(:one).update!(current: true, status: :active, role: :head_coach, end_date: nil)
    careers(:one).update!(current_date: "2026-12-31")
    tournament_editions(:one).update!(status: :completed)
    tournament_editions(:one).fixtures.update_all(status: Fixture.statuses[:completed])
    TournamentParticipation.find_or_create_by!(tournament_edition: tournament_editions(:one), club: clubs(:one)).update!(position: 1)
    TournamentParticipation.find_or_create_by!(tournament_edition: tournament_editions(:one), club: clubs(:two)).update!(position: 2)

    assert_difference "TournamentEdition.count", 1 do
      post rollover_career_path(careers(:one))
    end

    next_edition = tournament_editions(:one).tournament.tournament_editions.find_by!(season_year: 2027)
    assert_redirected_to career_path(careers(:one))
    assert_equal next_edition.fixtures.order(:scheduled_on, :kickoff_minute, :round).first.scheduled_on, careers(:one).reload.current_date
  end
end
