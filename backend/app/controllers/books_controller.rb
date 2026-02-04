class BooksController < ApplicationController
  before_action :set_book, only: %i[show edit update destroy]
  before_action :create_telegram_discussion, only: :show

  def index
    @tags = Tag.all.limit(10).order(:name)
    @active_tag = params[:tag]

    books = Book.order(created_at: :desc)
    if @active_tag.present?
      books = books.joins(:tags).where(tags: { name: @active_tag })
    end

    set_page_and_extract_portion_from books

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def show; end

  def new
    @book = Book.new
  end

  def edit; end

  def create
    @book = Book.new(book_params)
    if @book.save
      redirect_to @book, notice: "Book was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @book.update(book_params)
      redirect_to @book, notice: "Book was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @book.destroy
    redirect_to books_url, notice: "Book was successfully destroyed."
  end

  def search
    query = params[:query]
    @books = if query.present?
               Book.search(query).limit(10)
    else
               []
    end

    render layout: false
  end

  private

  def set_book
    @book = Book.find(params[:id])
  end

  def book_params
    params.require(:book).permit(:title, :author, :description, :published_at)
  end

  def create_telegram_discussion
    if !@book.telegram_post_id.present?
      message_id = TelegramService.new(@book).publish
      if message_id
        @book.update(telegram_post_id: message_id)
      end
    end
  end
end
