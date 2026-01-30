# frozen_string_literal: true

class TelegramMiniAppLoginController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :create ]

  # This action will be hit by a redirect from the frontend JS
  # It expects the Telegram initData as query parameters
  def create
    if telegram_data_is_valid?
      user_data = JSON.parse(params[:user])
      user = User.from_telegram_auth(user_data)
      sign_in(user)
      redirect_to root_path, notice: "Successfully logged in."
    else
      # We can't redirect to a login page, as it's inside the mini app.
      # Render an error message.
      render plain: "Authentication failed. Invalid data from Telegram.", status: :unauthorized
    end
  end

  private

  def telegram_data_is_valid?
    received_hash = params[:hash]
    return false unless received_hash

    # These are the expected fields in Telegram Mini App's initData (excluding 'hash' itself)
    valid_init_data_keys = %w[query_id user auth_date signature chat_instance chat_type]

    # Extract only the fields that are part of the original initData for validation
    # This correctly handles cases where other parameters (like 'signature', 'controller', 'action')
    # are present in the URL but should not be part of the hash calculation.
    data_to_check = params.slice(*valid_init_data_keys).to_unsafe_h

    # Build data_check_string from these fields, sorted alphabetically, as per Telegram's spec.
    data_check_string = data_to_check.map { |k, v| "#{k}=#{v}" }.sort.join("\n")

    # The secret key is derived from the bot's token for Mini App WebData validation.
    secret_key = OpenSSL::HMAC.digest("sha256", "WebAppData", ENV["TELEGRAM_BOT_TOKEN"])

    # Calculate the HMAC-SHA256 hash of the data-check-string with the derived secret_key.
    hash = OpenSSL::HMAC.hexdigest("sha256", secret_key, data_check_string)

    Rails.logger.info "Calculated hash: #{hash}"
    Rails.logger.info "Received hash: #{received_hash}"

    hash == received_hash
  end
end
