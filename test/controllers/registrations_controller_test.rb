require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "new" do
    get new_registration_path

    assert_response :success
  end

  test "create with valid attributes" do
    assert_difference "User.count", 1 do
      post registration_path, params: {
        user: {
          email_address: "new@example.com",
          password: "password",
          password_confirmation: "password"
        }
      }
    end

    assert_redirected_to root_path
    assert cookies[:session_id]
  end

  test "create with invalid attributes" do
    assert_no_difference "User.count" do
      post registration_path, params: {
        user: {
          email_address: "new@example.com",
          password: "password",
          password_confirmation: "different"
        }
      }
    end

    assert_response :unprocessable_content
    assert_nil cookies[:session_id]
  end
end
