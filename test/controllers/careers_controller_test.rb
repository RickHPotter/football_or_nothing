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
end
