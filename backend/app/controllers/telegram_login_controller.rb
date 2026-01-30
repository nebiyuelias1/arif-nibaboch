class TelegramLoginController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :callback ]

  def callback
    if telegram_data_is_valid?
      user = User.from_telegram_auth(telegram_params)
      sign_in(user)
      redirect_to root_path, notice: "Successfully logged in with Telegram."
    else
      redirect_to new_user_session_path, alert: "Telegram authentication failed."
    end
  end

  private

  def telegram_data_is_valid?
    data_check_string = telegram_params.to_h.except("hash").map { |k, v| "#{k}=#{v}" }.sort.join("\n")
    secret_key = Digest::SHA256.digest(ENV["TELEGRAM_BOT_TOKEN"])
    hash = OpenSSL::HMAC.hexdigest("sha256", secret_key, data_check_string)
    hash == telegram_params[:hash]
  end

  def telegram_params
    params.permit(:id, :first_name, :last_name, :username, :photo_url, :auth_date, :hash)
  end
end
