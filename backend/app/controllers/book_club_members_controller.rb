class BookClubMembersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_book_club

  def create
    @membership = @book_club.book_club_members.find_or_initialize_by(user: current_user)

    if @membership.persisted?
      @membership.destroy
      render json: { status: "left", count: @book_club.book_club_members_count - 1 }
    elsif @membership.save
      render json: { status: "joined", count: @book_club.book_club_members_count + 1 }
    else
      render json: { error: "Could not update membership" }, status: :unprocessable_entity
    end
  end

  private

  def set_book_club
    @book_club = BookClub.find(params[:book_club_id])
  end
end
