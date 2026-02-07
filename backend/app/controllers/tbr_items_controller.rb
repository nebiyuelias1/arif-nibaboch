class TbrItemsController < ApplicationController
  before_action :authenticate_user!

  def create
    @book = Book.find(params[:book_id])
    @tbr_item = @book.tbr_items.find_or_initialize_by(user: current_user)

    if @tbr_item.new_record? && @tbr_item.save
      respond_to do |format|
        format.html { redirect_to @book, notice: "Book added to your TBR list." }
        format.json { render json: { tbr_item: @tbr_item, in_tbr: true } }
      end
    else
      respond_to do |format|
        format.html { redirect_to @book, alert: "Failed to add book to TBR." }
        format.json { render json: { errors: @tbr_item.errors }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @book = Book.find(params[:book_id])
    @tbr_item = @book.tbr_items.find_by(user: current_user)

    if @tbr_item&.destroy
      respond_to do |format|
        format.html { redirect_to @book, notice: "Book removed from your TBR list." }
        format.json { render json: { in_tbr: false } }
      end
    else
      respond_to do |format|
        format.html { redirect_to @book, alert: "Failed to remove book from TBR." }
        format.json { render json: { errors: "Book not found in TBR" }, status: :unprocessable_entity }
      end
    end
  end
end
