require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "shows onboarding when user has no career" do
    user = User.create!(
      email_address: "onboarding@example.com",
      password: "password",
      password_confirmation: "password"
    )
    sign_in_as(user)

    get root_path

    assert_response :success
    assert_select "a", "Create manager"
  end

  test "shows current career when user has a manager" do
    sign_in_as(users(:one))

    get root_path

    assert_response :success
    assert_select "a", "Open career"
  end
end
