class BookReadsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_book_club
  before_action :set_book_read, only: [ :show, :edit, :update ]
  before_action :authorize_club_owner!, only: [ :new, :create, :edit, :update ]

  def index
    @tab = params[:tab] || "upcoming"
    if @tab == "past"
      @reads = @book_club.book_reads.includes(:book).completed.order(end_date: :desc)
    else
      @reads = @book_club.book_reads.includes(:book).where(status: [ :active, :upcoming ]).order(start_date: :asc)
    end
  end

  def show
  end

  def new
    @book_read = @book_club.book_reads.build
  end

  def edit
  end

  def create
    @book_read = @book_club.book_reads.build(book_read_params)
    if @book_read.save
      redirect_to book_club_book_read_path(@book_club, @book_read), notice: "Book read created successfully."
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

  def authorize_club_owner!
    unless @book_club.owner == current_user
      redirect_to book_club_path(@book_club), alert: "You are not authorized to perform this action."
    end
  end

  def book_read_params
    params.require(:book_read).permit(:book_id, :start_date, :end_date, :status)
  end
end
