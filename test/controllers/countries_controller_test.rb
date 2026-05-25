# frozen_string_literal: true

require "test_helper"

class CountriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
    @career = careers(:one)
  end

  test "index shows countries with counts" do
    get career_countries_path(@career)

    assert_response :success
    assert_select "h1", "Countries"
    assert_select "td", countries(:one).name
    assert_select "a", "Clubs"
    assert_select "a", "Tournaments"
  end

  test "show displays country clubs and tournaments" do
    get career_country_path(@career, countries(:one))

    assert_response :success
    assert_select "h1", countries(:one).name
    assert_select "a", clubs(:one).name
    assert_select "a", tournaments(:one).name
  end
end
