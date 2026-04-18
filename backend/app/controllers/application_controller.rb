class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  protected

  def authorize_club_owner!(club, redirect_url: nil)
    unless club.owner == current_user
      redirect_to (redirect_url || book_club_path(club)), alert: "You are not authorized to perform this action."
    end
  end
end
