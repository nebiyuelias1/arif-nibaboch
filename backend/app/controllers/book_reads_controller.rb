class BookReadsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_book_club

  def index
    @book_reads = @book_club.book_reads.order(created_at: :desc)
  end

  def show
    @book_read = @book_club.book_reads.find(params[:id])
  end

  def new
    @book_read = @book_club.book_reads.build
  end

  def create
    @book_read = @book_club.book_reads.build(book_read_params)
    if @book_read.save
      redirect_to book_club_book_read_path(@book_club, @book_read), notice: "Book read created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_book_club
    @book_club = BookClub.find(params[:book_club_id])
  end

  def book_read_params
    params.require(:book_read).permit(:book_id, :start_date, :end_date, :status)
  end
end
