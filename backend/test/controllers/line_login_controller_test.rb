require "test_helper"

class LineLoginControllerTest < ActionDispatch::IntegrationTest
  test "authorize redirects to LINE authorization URL" do
    get line_login_authorize_url
    assert_response :redirect
    assert_match "access.line.me/oauth2/v2.1/authorize", response.location
    assert_match "response_type=code", response.location
    assert session[:line_oauth_state].present?
  end

  test "callback fails when error param is present" do
    get line_login_callback_url, params: { error: "access_denied", error_description: "User denied access" }
    assert_redirected_to new_user_session_path
    assert_equal "LINE authentication failed: User denied access", flash[:alert]
  end

  test "callback fails when state is missing" do
    get line_login_callback_url, params: { code: "test_code" }
    assert_redirected_to new_user_session_path
    assert_equal "LINE authentication failed: Invalid state parameter.", flash[:alert]
  end

  test "callback fails when state does not match" do
    get line_login_authorize_url
    get line_login_callback_url, params: { code: "test_code", state: "wrong_state" }
    assert_redirected_to new_user_session_path
    assert_equal "LINE authentication failed: Invalid state parameter.", flash[:alert]
  end

  test "callback signs in user with valid LINE profile" do
    line_user_id = "U1234567890abcdef"
    display_name = "Test LINE User"

    get line_login_authorize_url
    state = session[:line_oauth_state]

    fake_token_response = Struct.new(:body).new('{"access_token":"fake_token"}')
    profile_body = "{\"userId\":\"#{line_user_id}\",\"displayName\":\"#{display_name}\"}"
    fake_profile_response = Struct.new(:body).new(profile_body)
    fake_http = Object.new
    fake_http.define_singleton_method(:request) { |_req| fake_profile_response }

    Net::HTTP.stub(:post_form, fake_token_response) do
      Net::HTTP.stub(:start, ->(*_args, &blk) { blk.call(fake_http) }) do
        assert_difference("User.count", 1) do
          get line_login_callback_url, params: { code: "valid_code", state: state }
        end
      end
    end

    assert_redirected_to root_path
    assert_equal "Successfully logged in with LINE.", flash[:notice]
    assert_equal line_user_id, User.last.line_id
    assert_equal display_name, User.last.name
  end

  test "callback does not create duplicate user on second login" do
    line_user_id = "U9876543210fedcba"
    User.create!(
      line_id: line_user_id,
      name: "Existing LINE User",
      email: "#{line_user_id.downcase}@line.com",
      password: Devise.friendly_token[0, 20]
    )

    get line_login_authorize_url
    state = session[:line_oauth_state]

    fake_token_response = Struct.new(:body).new('{"access_token":"fake_token"}')
    profile_body = "{\"userId\":\"#{line_user_id}\",\"displayName\":\"Updated Name\"}"
    fake_profile_response = Struct.new(:body).new(profile_body)
    fake_http = Object.new
    fake_http.define_singleton_method(:request) { |_req| fake_profile_response }

    Net::HTTP.stub(:post_form, fake_token_response) do
      Net::HTTP.stub(:start, ->(*_args, &blk) { blk.call(fake_http) }) do
        assert_no_difference("User.count") do
          get line_login_callback_url, params: { code: "valid_code", state: state }
        end
      end
    end

    assert_redirected_to root_path
  end

  test "callback fails when token exchange raises an error" do
    get line_login_authorize_url
    state = session[:line_oauth_state]

    token_response = Minitest::Mock.new
    token_response.expect(:body, '{"error":"invalid_grant"}')

    Net::HTTP.stub(:post_form, token_response) do
      get line_login_callback_url, params: { code: "bad_code", state: state }
    end

    assert_redirected_to new_user_session_path
    assert_equal "LINE authentication failed: Could not obtain access token.", flash[:alert]
  end
end
