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

    # The data-check-string is a concatenation of all received fields,
    # sorted alphabetically, in the format key=<value> with a line
    # feed character ('\n', 0x0A) used as separator.
    # We received them as params from the redirect.
    data_check_string = params.to_unsafe_h.except("hash").map { |k, v| "#{k}=#{v}" }.sort.join("\n")

    # The secret key is the HMAC-SHA-256 signature of the bot's token
    # with the constant string "WebAppData" as data.
    secret_key = OpenSSL::HMAC.digest("sha256", "WebAppData", ENV["TELEGRAM_BOT_TOKEN"])
    # The hash is the hexadecimal representation of the HMAC-SHA-256 signature
    # of the data-check-string with the secret_key.
    hash = OpenSSL::HMAC.hexdigest("sha256", secret_key, data_check_string)
    Rails.logger.info "Calculated hash: #{hash}"
    Rails.logger.info "Received hash: #{received_hash}"
    hash == received_hash
  end
end
