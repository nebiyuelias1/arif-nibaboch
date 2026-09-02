class RatingsController < ApplicationController
  before_action :authenticate_user!

  def create
    @book = Book.find(params[:book_id])
    @rating = @book.ratings.find_or_initialize_by(user: current_user)

    if @rating.update(rating_params)
      respond_to do |format|
        format.html { redirect_to @book, notice: "Rating saved successfully." }
        format.json { render json: { rating: @rating, average: @book.average_rating } }
      end
    else
      respond_to do |format|
        format.html { redirect_to @book, alert: "Failed to save rating." }
        format.json { render json: { errors: @rating.errors }, status: :unprocessable_content }
      end
    end
  end

  private

  def rating_params
    params.require(:rating).permit(:score)
  end
end
