class BookClubsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_book_club, only: [ :show, :edit, :update ]
  before_action -> { authorize_club_owner!(@club) }, only: [ :edit, :update ]

  def index
    @clubs = BookClub.all.order(created_at: :desc)
  end

  def show
    @current_read = @club.book_reads.where("meetup_time >= ?", Time.current).order(meetup_time: :desc).first
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

  def update
    if @club.update(club_params)
      redirect_to book_club_path(@club), notice: "Book Club updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def edit
  end

  private

  def club_params
    params.require(:book_club).permit(:name, :description, :is_private, :cover_photo)
  end

  def set_book_club
    @club = BookClub.find(params[:id])
  end
end
