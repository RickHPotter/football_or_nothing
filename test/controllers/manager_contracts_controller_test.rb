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

  test "create accepts any unmanaged active club as starting job" do
    @club.update!(reputation: 20, international: true)

    assert_difference "ManagerContract.where(current: true).count", 1 do
      post career_manager_contracts_path(@career), params: { club_id: @club.id }
    end

    assert_redirected_to career_path(@career)
    assert_equal @club, @career.manager.reload.current_club
  end

  test "create rejects club with current manager" do
    manager_contracts(:two).update!(club: @club, current: true, status: :active, end_date: nil)

    assert_no_difference "ManagerContract.where(current: true).count" do
      post career_manager_contracts_path(@career), params: { club_id: @club.id }
    end

    assert_redirected_to career_path(@career)
    assert @career.manager.reload.unemployed?
  end
end
