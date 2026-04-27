class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :user_device_language

  protected

  def after_sign_in_path_for(resource)
    root_path
  end

  def after_sign_up_path_for(resource)
    root_path
  end

  def authorize_club_owner!(club, redirect_url: nil)
    unless club.owner == current_user
      redirect_to (redirect_url || book_club_path(club)), alert: "You are not authorized to perform this action."
    end
  end

  private

  def user_device_language
    @user_device_language ||= begin
      lang = request.env["HTTP_ACCEPT_LANGUAGE"]&.split(",")&.first
      (lang.presence || "EN").upcase
    end
  end
end
