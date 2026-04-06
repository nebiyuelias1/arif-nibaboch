require "net/http"
require "uri"
require "json"

class LineLoginController < ApplicationController
  # The callback is a GET redirect from LINE's servers, which cannot include
  # a Rails CSRF token. CSRF protection is provided by the OAuth `state` parameter
  # validated in the callback action.
  skip_before_action :verify_authenticity_token, only: [ :callback ]

  LINE_AUTH_URL = "https://access.line.me/oauth2/v2.1/authorize"
  LINE_TOKEN_URL = "https://api.line.me/oauth2/v2.1/token"
  LINE_PROFILE_URL = "https://api.line.me/v2/profile"

  def authorize
    state = SecureRandom.hex(16)
    session[:line_oauth_state] = state

    query = URI.encode_www_form(
      response_type: "code",
      client_id: ENV["LINE_CHANNEL_ID"],
      redirect_uri: line_login_callback_url,
      state: state,
      scope: "profile"
    )

    redirect_to "#{LINE_AUTH_URL}?#{query}", allow_other_host: true
  end

  def callback
    if params[:error].present?
      redirect_to new_user_session_path, alert: "LINE authentication failed: #{params[:error_description]}"
      return
    end

    unless params[:state].present? && params[:state] == session.delete(:line_oauth_state)
      redirect_to new_user_session_path, alert: "LINE authentication failed: Invalid state parameter."
      return
    end

    access_token = exchange_code_for_token(params[:code])

    if access_token.nil?
      redirect_to new_user_session_path, alert: "LINE authentication failed: Could not obtain access token."
      return
    end

    profile = fetch_profile(access_token)

    if profile.nil?
      redirect_to new_user_session_path, alert: "LINE authentication failed: Could not fetch profile."
      return
    end

    user = User.from_line_auth(profile)
    sign_in(user)
    redirect_to root_path, notice: "Successfully logged in with LINE."
  end

  private

  def exchange_code_for_token(code)
    uri = URI(LINE_TOKEN_URL)
    response = Net::HTTP.post_form(uri, {
      grant_type: "authorization_code",
      code: code,
      redirect_uri: line_login_callback_url,
      client_id: ENV["LINE_CHANNEL_ID"],
      client_secret: ENV["LINE_CHANNEL_SECRET"]
    })

    result = JSON.parse(response.body)
    result["access_token"]
  rescue StandardError => e
    Rails.logger.error "LINE token exchange error: #{e.message}"
    nil
  end

  def fetch_profile(access_token)
    uri = URI(LINE_PROFILE_URL)
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{access_token}"

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    JSON.parse(response.body)
  rescue StandardError => e
    Rails.logger.error "LINE profile fetch error: #{e.message}"
    nil
  end
end
