class BookReadRsvpsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_book_club
  before_action :set_book_read
  before_action :ensure_not_past_event
  before_action :ensure_membership!, only: [ :create, :update ]

  def create
    @rsvp = BookReadRsvp.rsvp!(book_read: @book_read, user: current_user, status: :going)
    @rsvp_users = @book_read.book_read_rsvps.going.includes(:user).map(&:user)
    @waitlisted_count = @book_read.book_read_rsvps.waitlisted.count

    respond_to do |format|
      format.html { redirect_to book_club_book_read_path(@book_club, @book_read), notice: rsvp_notice(@rsvp) }
      format.turbo_stream { flash.now[:notice] = rsvp_notice(@rsvp) }
    end
  end

  def update
    status = params.dig(:book_read_rsvp, :status) || :going
    @rsvp = BookReadRsvp.rsvp!(book_read: @book_read, user: current_user, status: status)
    @rsvp_users = @book_read.book_read_rsvps.going.includes(:user).map(&:user)
    @waitlisted_count = @book_read.book_read_rsvps.waitlisted.count

    respond_to do |format|
      format.html { redirect_to book_club_book_read_path(@book_club, @book_read), notice: rsvp_notice(@rsvp) }
      format.turbo_stream { flash.now[:notice] = rsvp_notice(@rsvp) }
    end
  end

  private

  def ensure_not_past_event
    if @book_read.meetup_time&.past?
      redirect_to book_club_book_read_path(@book_club, @book_read), alert: t("rsvp_closed")
    end
  end

  def set_book_club
    @book_club = BookClub.find(params[:book_club_id])
  end

  def set_book_read
    @book_read = @book_club.book_reads.find(params[:book_read_id])
  end

  def ensure_membership!
    if @book_club.is_private && !@book_club.has_member?(current_user)
      redirect_to book_club_book_read_path(@book_club, @book_read),
        alert: "This is a private club. Join the club first to RSVP."
    else
      @book_club.book_club_members.find_or_create_by!(user: current_user)
    end
  end

  def rsvp_notice(rsvp)
    return "You are waitlisted for this read." if rsvp.waitlisted?
    return "Your RSVP was updated." if rsvp.cancelled?

    "You are going to this read."
  end
end
