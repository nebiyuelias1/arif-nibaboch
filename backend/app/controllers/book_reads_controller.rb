class BookReadsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_book_club
  before_action :set_book_read, only: [ :show, :edit, :update ]
  before_action -> { authorize_club_owner!(@book_club) }, only: [ :new, :create, :edit, :update ]

  def index
    @tab = params[:tab] || "upcoming"
    if @tab == "past"
      @reads = @book_club.book_reads.includes(:book).completed.order(end_date: :desc)
    else
      @reads = @book_club.book_reads.includes(:book).where(status: [ :active, :upcoming ]).order(start_date: :asc)
    end
  end

  def show
    if user_signed_in? && @book_club.owner == current_user
      @discussion_questions = @book_read.discussion_questions.order(:position)
    else
      @discussion_questions = @book_read.discussion_questions.revealed.order(:position)
    end
  end

  def new
    @book_read = @book_club.book_reads.build
  end

  def edit
  end

  def create
    @book_read = @book_club.book_reads.build(book_read_params)

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
      :meetup_time,
      :meetup_location,
      poll_attributes: [
        :id, :text, :end_date,
        poll_options_attributes: [ :id, :book_id, :content, :_destroy ]
      ]
    )
  end
end
