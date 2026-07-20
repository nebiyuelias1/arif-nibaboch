class PagesController < ApplicationController
  before_action :authenticate_user!, only: [:home]
  
  def home
  end

  def privacy
  end

  def terms
  end
end
