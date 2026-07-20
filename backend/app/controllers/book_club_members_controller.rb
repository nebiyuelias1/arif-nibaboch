class BookClubMembersController < ApplicationController
  before_action :store_return_location!, unless: :user_signed_in?
  before_action :authenticate_user!
  before_action :set_book_club
  before_action :require_admin, only: [ :update, :destroy ]

  def create
    @membership = @book_club.book_club_members.find_or_initialize_by(user: current_user)

    if @membership.persisted?
      @membership.destroy
      @status = "left"
      @count = @book_club.reload.book_club_members_count
    elsif @membership.save
      @status = "joined"
      @count = @book_club.reload.book_club_members_count
    else
      respond_to do |format|
        format.json { render json: { error: "Could not update membership" }, status: :unprocessable_entity }
        format.html { redirect_back fallback_location: @book_club, alert: "Could not update membership" }
      end
      return
    end

    respond_to do |format|
      format.json { render json: { status: @status, count: @count } }
      format.html { redirect_back fallback_location: @book_club }
      format.turbo_stream
    end
  end

  def update
    @membership = @book_club.book_club_members.find(params[:id])
    
    if @membership.user_id == @book_club.owner_id
      respond_to do |format|
        format.html { redirect_to @book_club, alert: "Cannot change the role of the club owner." }
        format.turbo_stream { flash.now[:alert] = "Cannot change the role of the club owner." }
      end
      return
    end

    if @membership.update(role: params[:role])
      respond_to do |format|
        format.html { redirect_to @book_club, notice: "Membership updated." }
        format.turbo_stream { flash.now[:notice] = "Membership updated." }
      end
    else
      respond_to do |format|
        format.html { redirect_to @book_club, alert: "Could not update membership." }
        format.turbo_stream { flash.now[:alert] = "Could not update membership." }
      end
    end
  end

  def destroy
    @membership = @book_club.book_club_members.find(params[:id])
    
    if @membership.user_id == @book_club.owner_id
      respond_to do |format|
        format.html { redirect_to @book_club, alert: "Cannot remove the club owner." }
        format.turbo_stream { flash.now[:alert] = "Cannot remove the club owner." }
      end
      return
    end

    @membership.destroy
    respond_to do |format|
      format.html { redirect_to @book_club, notice: "Member removed." }
      format.turbo_stream { flash.now[:notice] = "Member removed." }
    end
  end

  private

  def set_book_club
    @book_club = BookClub.find(params[:book_club_id])
  end

  def require_admin
    unless @book_club.book_club_members.exists?(user: current_user, role: :admin)
      redirect_to @book_club, alert: "You do not have permission to do that."
    end
  end

  def store_return_location!
    store_location_for(:user, request.referer || book_club_path(params[:book_club_id]))
  end
end
