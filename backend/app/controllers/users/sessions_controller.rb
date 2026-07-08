class Users::SessionsController < Devise::SessionsController
  before_action :set_remember_me_for_native_app, only: [:create]

  private

  def set_remember_me_for_native_app
    if hotwire_native_app? && params[:user]
      params[:user][:remember_me] = "1"
    end
  end
end
