require "test_helper"

class BooksFtsTest < ActiveSupport::TestCase
  def setup
    # Ensure migration has run
    unless ActiveRecord::Base.connection.table_exists?(:books_fts)
      skip "books_fts table not created yet - run migrations first"
    end
  end

  test "books_fts virtual table exists" do
    assert ActiveRecord::Base.connection.table_exists?(:books_fts),
           "books_fts virtual table should exist"
  end

  test "books_fts is automatically populated on book creation" do
    # Create a new book
    book = Book.create!(
      title: "Test FTS Book",
      author: "Test Author",
      description: "A book for testing full-text search functionality"
    )

    # Query the FTS table directly
    result = ActiveRecord::Base.connection.execute(
      "SELECT rowid FROM books_fts WHERE books_fts MATCH 'Test'"
    )

    assert result.any?, "New book should be indexed in books_fts"

    # Cleanup
    book.destroy
  end

  test "books_fts is updated when book is updated" do
    # Create a book
    book = Book.create!(
      title: "Original Title",
      author: "Original Author",
      description: "Original description"
    )

    # Update the book
    book.update!(title: "Updated Unique Title")

    # Search for the updated title
    result = ActiveRecord::Base.connection.execute(
      "SELECT rowid FROM books_fts WHERE books_fts MATCH 'Updated Unique'"
    )

    assert result.any?, "Updated book should be searchable in books_fts"

    # Cleanup
    book.destroy
  end

  test "books_fts is cleaned up when book is deleted" do
    # Create a book
    book = Book.create!(
      title: "Book to Delete",
      author: "Delete Author",
      description: "This book will be deleted"
    )

    book_id = book.id

    # Verify it's in FTS
    result = ActiveRecord::Base.connection.execute(
      "SELECT rowid FROM books_fts WHERE rowid = #{book_id}"
    )
    assert result.any?, "Book should be in books_fts before deletion"

    # Delete the book
    book.destroy

    # Verify it's removed from FTS
    result = ActiveRecord::Base.connection.execute(
      "SELECT rowid FROM books_fts WHERE rowid = #{book_id}"
    )
    assert_empty result, "Deleted book should be removed from books_fts"
  end

  test "full-text search works on multiple columns" do
    # Create books with different searchable content
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

    # Search for "Ruby" which appears in different columns
    result = ActiveRecord::Base.connection.execute(
      "SELECT rowid FROM books_fts WHERE books_fts MATCH 'Ruby'"
    )

    rowids = result.map { |row| row[0] }

    assert_includes rowids, book1.id, "Should find book with Ruby in title"
    assert_includes rowids, book2.id, "Should find book with Ruby in author"

    # Cleanup
    book1.destroy
    book2.destroy
  end
end
