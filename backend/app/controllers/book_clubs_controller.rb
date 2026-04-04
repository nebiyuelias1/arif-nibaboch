class BookClubsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]

  def index
    @clubs = BookClub.all.order(created_at: :desc)
  end

  def show
    @club = BookClub.find(params[:id])
    @current_read = @club.book_reads.active.order(start_date: :asc).first || @club.book_reads.upcoming.order(start_date: :asc).first
  end

  def new
    @club = BookClub.new
  end

  def create
    @club = current_user.owned_book_clubs.build(club_params)
    if @club.save
      redirect_to book_club_path(@club), notice: "Book Club created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def club_params
    params.require(:book_club).permit(:name, :description, :is_private, :cover_photo)
  end
end
