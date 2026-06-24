class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  around_action :set_time_zone
  helper_method :user_device_language

  before_action :set_locale

  protected

 def set_locale
  if I18n.available_locales.map(&:to_s).include?(params[:locale])
    I18n.locale = params[:locale]
  else
    I18n.locale = I18n.default_locale
  end
end

  def set_time_zone(&block)
    time_zone = cookies[:user_time_zone] || Time.zone.name
    Time.use_zone(time_zone, &block)
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || super
  end

  def after_sign_up_path_for(resource)
    stored_location_for(resource) || super
  end

  def authorize_club_owner!(club, redirect_url: nil)
    unless club.owner == current_user || club.book_club_members.exists?(user: current_user, role: :admin)
      redirect_to (redirect_url || book_club_path(club)), alert: "You are not authorized to perform this action."
    end
  end
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :language])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :avatar, :language])
  end
  private

  def user_device_language
    @user_device_language ||= begin
      lang = request.env["HTTP_ACCEPT_LANGUAGE"]&.split(",")&.first
      (lang.presence || "EN").upcase
    end
  end
end
