class ReviewLikesController < ApplicationController
  before_action :authenticate_user!

  def create
    @book = Book.find(params[:book_id])
    @review = @book.reviews.find(params[:review_id])
    @review_like = @review.review_likes.find_by(user: current_user)

    if @review_like
      @review_like.destroy
      liked = false
    else
      @review_like = @review.review_likes.create(user: current_user)
      unless @review_like.persisted?
        respond_to do |format|
          format.json do
            render json: { errors: @review_like.errors.full_messages }, status: :unprocessable_entity
          end
        end
        return
      end
      liked = true
    end

    respond_to do |format|
      format.json { render json: { liked: liked, likes_count: @review.reload.review_likes_count } }
    end
  end
end
