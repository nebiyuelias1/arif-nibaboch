class Admin::DashboardController < ApplicationController
  # This ensures only logged-in admins can see the dashboard
  before_action :authenticate_user!
  before_action :ensure_admin!

  def index
    @books_count = Book.count
    @users_count = User.count
    # Add any other data you want to see in your admin panel
  end

  private

  def ensure_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: "Access denied! Admins only."
    end
  end
end