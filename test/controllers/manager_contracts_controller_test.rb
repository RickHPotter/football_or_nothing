# frozen_string_literal: true

require "test_helper"

class ManagerContractsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
    @career = careers(:one)
    @club = clubs(:one)
  end

  test "create accepts available job" do
    assert_difference "ManagerContract.where(current: true).count", 1 do
      post career_manager_contracts_path(@career), params: { club_id: @club.id }
    end

    assert_redirected_to career_path(@career)
    assert @career.manager.reload.active?
    assert_equal @club, @career.manager.current_club
  end

  test "create rejects unavailable job" do
    @club.update!(reputation: 20)

    assert_no_difference "ManagerContract.where(current: true).count" do
      post career_manager_contracts_path(@career), params: { club_id: @club.id }
    end

    assert_redirected_to career_path(@career)
    assert @career.manager.reload.unemployed?
  end
end
