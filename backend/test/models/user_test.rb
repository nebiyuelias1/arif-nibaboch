require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "from_line_auth creates a new user from LINE profile" do
    profile = { "userId" => "U_new_line_user", "displayName" => "LINE User" }

    assert_difference("User.count", 1) do
      user = User.from_line_auth(profile)
      assert_equal "U_new_line_user", user.line_id
      assert_equal "LINE User", user.name
      assert_equal "u_new_line_user@line.com", user.email
    end
  end

  test "from_line_auth updates existing user instead of creating a new one" do
    existing = User.create!(
      line_id: "U_existing_line",
      name: "Old Name",
      email: "U_existing_line@line.com",
      password: Devise.friendly_token[0, 20]
    )

    profile = { "userId" => "U_existing_line", "displayName" => "New Name" }

    assert_no_difference("User.count") do
      user = User.from_line_auth(profile)
      assert_equal existing.id, user.id
      assert_equal "New Name", user.name
    end
  end
end
