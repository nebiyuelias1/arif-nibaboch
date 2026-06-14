class BooksController < ApplicationController
  before_action :set_book, only: %i[show edit update destroy]

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

  def show
    @reviews = @book.reviews.includes(:user).where(parent_id: nil).order(created_at: :desc)
    if current_user
      @liked_review_ids = ReviewLike.where(user_id: current_user.id, review_id: @reviews).pluck(:review_id)
    else
      @liked_review_ids = []
    end
  end

  def new
    @book = Book.new
  end

  def edit; end

  def create
    @book = Book.new(book_params)
    respond_to do |format|
      if @book.save
        format.html { redirect_to @book }
        format.json { render json: @book, status: :created }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
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
               local_results = Book.full_text_search(query).limit(10).to_a

               if local_results.size < 5
                 lookup_results = BookLookup.find_many(title: query, author: query) || []
                 external_books = lookup_results.map { |res| map_lookup_result_to_book(res) }

                 combined = (local_results + external_books).uniq do |book|
                   [ book.title.to_s.downcase.strip, book.author.to_s.downcase.strip ]
                 end
                 combined.first(10)
               else
                 local_results
               end
    else
               []
    end

    respond_to do |format|
      format.html { render layout: false }
      format.json do
        render json: @books.map { |book|
          {
            id: book.id,
            title: book.title,
            author: book.author,
            cover_url: book.cover_image,
            persisted: book.persisted?,
            # Include attributes for unpersisted books so they can be saved
            attributes: book.persisted? ? {} : book.attributes.except("id", "created_at", "updated_at")
          }
        }
      end
    end
  end

  private

  def map_lookup_result_to_book(result)
    Book.new(
      title: result.title,
      author: result.author.presence || "Unknown Author",
      cover_image: result.cover_image,
      isbn: result.isbn,
      publisher: result.publisher,
      published_at: result.published_at,
      description: result.description,
      page_count: result.page_count,
      language: result.language,
      source: result.source,
      source_url: result.source_url
    )
  end

  def set_book
    @book = Book.find(params[:id])
  end

  def book_params
    params.require(:book).permit(
      :title, :author, :description, :published_at, :language,
      :cover_image, :publisher, :isbn, :source, :source_url,
      :title_en, :title_romanized, :author_romanized, :page_count
    )
  end
end
