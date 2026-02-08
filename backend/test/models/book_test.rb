require "test_helper"

class BookTest < ActiveSupport::TestCase
  def setup
    Book.rebuild_search_index
  end

  test "books_fts virtual table exists" do
    sql_query = <<-SQL
      SELECT name FROM sqlite_master WHERE type='table' AND name='books_fts'
    SQL

    result = ActiveRecord::Base.connection.execute(sql_query)
    assert result.any?, "books_fts virtual table should exist"
  end

  test "should not save book without title" do
    book = Book.new(author: "Test Author")
    assert_not book.save, "Saved the book without a title"
  end

  test "books_fts is automatically populated on book creation" do
    book = Book.create!(
      title: "Test FTS Book",
      author: "Test Author",
      description: "A book for testing full-text search functionality"
    )

    result = ActiveRecord::Base.connection.execute(
      "SELECT rowid FROM books_fts WHERE books_fts MATCH 'Test'"
    )

    assert result.any?, "New book should be indexed in books_fts"

    book.destroy
  end

  test "books_fts is updated when book is updated" do
    book = Book.create!(
      title: "Original Title",
      author: "Original Author",
      description: "Original description"
    )

    book.update!(title: "Updated Unique Title")

    result = ActiveRecord::Base.connection.execute(
      "SELECT rowid FROM books_fts WHERE books_fts MATCH 'Updated Unique'"
    )

    assert result.any?, "Updated book should be searchable in books_fts"

    book.destroy
  end

  test "books_fts is cleaned up when book is deleted" do
    book = Book.create!(
      title: "Book to Delete",
      author: "Delete Author",
      description: "This book will be deleted"
    )

    book_id = book.id

    result = ActiveRecord::Base.connection.execute(
      ActiveRecord::Base.sanitize_sql_array([ "SELECT rowid FROM books_fts WHERE rowid = ?", book_id ])
    )
    assert result.any?, "Book should be in books_fts before deletion"

    book.destroy

    result = ActiveRecord::Base.connection.execute(
      ActiveRecord::Base.sanitize_sql_array([ "SELECT rowid FROM books_fts WHERE rowid = ?", book_id ])
    )

    assert_empty result, "Deleted book should be removed from books_fts"
  end

 test "full-text search works on multiple columns" do
    book1 = Book.create!(
      title: "Ruby Programming",
      author: "Test Author",
      description: "Learn Ruby programming language"
    )

    book2 = Book.create!(
      title: "Python Guide",
      author: "Ruby Smith",
      description: "Python programming guide"
    )

    result = Book.full_text_search("Ruby")

    rowids = result.map { |row| row.id }

    assert_includes rowids, book1.id, "Should find book with Ruby in title"
    assert_includes rowids, book2.id, "Should find book with Ruby in author"

    book1.destroy
    book2.destroy
  end

  test "use full text search for searching book" do
    books = Book.full_text_search("ለምትኬ")
    assert_includes books.pluck(:title), "ለምትኬ"
    assert_includes books.pluck(:author), "ደረጀ ለማ ደገፉ"

    books = Book.full_text_search("lamtké")
    assert_includes books.pluck(:title), "ለምትኬ"
    assert_includes books.pluck(:author), "ደረጀ ለማ ደገፉ"

    # TODO: Search using romanization
    # might need to standardize the romanization of amharic
    # books = Book.full_text_search("lemetke")
    # assert_includes books.pluck(:title), "ለምትኬ"
    # assert_includes books.pluck(:author), "ደረጀ ለማ ደገፉ"
  end

  test "creates telegram discussion after book creation" do
    mock_service = Minitest::Mock.new
    mock_service.expect(:publish, "123456")

    TelegramService.stub(:new, mock_service) do
      book = Book.create!(
        title: "Test Book for Telegram",
        author: "Test Author"
      )

      assert_not_nil book.telegram_post_id
      assert_equal "123456", book.telegram_post_id
      book.destroy
    end
    mock_service.verify
  end

  test "does not create telegram discussion if telegram_post_id already exists" do
    mock_service = Minitest::Mock.new
    TelegramService.stub(:new, mock_service) do
      book = Book.create!(
        title: "Book with Existing Telegram Post",
        author: "Test Author",
        telegram_post_id: "existing_id"
      )
      assert_equal "existing_id", book.telegram_post_id
      book.destroy
    end

    mock_service.verify
  end

  test "skips telegram discussion creation when skip_telegram_callback is true" do
    mock_service = Minitest::Mock.new

    TelegramService.stub(:new, mock_service) do
      book = Book.new(
        title: "Book Skipping Telegram",
        author: "Test Author"
      )
      book.skip_telegram_callback = true
      book.save!

      assert_nil book.telegram_post_id
      book.destroy
    end

    # Verify that TelegramService.new was never called
    mock_service.verify
  end
end
