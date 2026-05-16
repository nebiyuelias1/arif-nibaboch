class BookReadsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_book_club
  before_action :set_book_read, only: [ :show, :edit, :update ]
  before_action -> { authorize_club_owner!(@book_club) }, only: [ :new, :create, :edit, :update ]

  def index
    @tab = params[:tab] || "upcoming"
    if @tab == "past"
      @reads = @book_club.book_reads.includes(:book).where("meetup_time < ?", Time.current).order(meetup_time: :desc)
    else
      @reads = @book_club.book_reads.includes(:book).where("meetup_time >= ?", Time.current).order(meetup_time: :desc)
    end
  end

  def show
    discussion_questions = @book_read.discussion_questions.includes(:question_translations)
    if user_signed_in? && @book_club.owner == current_user
      @discussion_questions = discussion_questions.order(:position)
    else
      @discussion_questions = discussion_questions
        .revealed
        .or(discussion_questions.where(user: current_user))
        .order(:position)
    end

    draft_content = if user_signed_in?
      session.delete(:discussion_question_draft)
    else
      session[:discussion_question_draft]
    end
    @new_discussion_question = DiscussionQuestion.new(content: draft_content)
    @rsvp = @book_read.book_read_rsvps.find_by(user: current_user) if user_signed_in?
    @rsvp_users = @book_read.book_read_rsvps.going.includes(:user).map(&:user)
    @rsvp_records = @book_read.book_read_rsvps.includes(:user).order(created_at: :asc)
  end

  def new
    @book_read = @book_club.book_reads.build(host: current_user)
  end

  def edit
  end

  def create
    @book_read = @book_club.book_reads.build(book_read_params.merge(host: current_user))

    if params[:selection_type] == "book"
      @book_read.poll = nil
    elsif params[:selection_type] == "poll"
      @book_read.book_id = nil
    end

    if @book_read.save
      redirect_to book_club_book_read_path(@book_club, @book_read), notice: "Book read scheduled successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @book_read.update(book_read_params)
      redirect_to book_club_book_read_path(@book_club, @book_read), notice: "Book read was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_book_club
    @book_club = BookClub.find(params[:book_club_id])
  end

  def set_book_read
    @book_read = @book_club.book_reads.find(params[:id])
  end

  def book_read_params
    params.require(:book_read).permit(
      :book_id,
      :max_capacity,
      :meetup_time,
      :meetup_location,
      poll_attributes: [
        :id, :text, :end_date,
        poll_options_attributes: [ :id, :book_id, :content, :_destroy ]
      ]
    )
  end
end
