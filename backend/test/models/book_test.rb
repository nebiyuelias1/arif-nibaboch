require "test_helper"

class BookTest < ActiveSupport::TestCase
  test "should not save book without title" do
    book = Book.new(author: "Test Author")
    assert_not book.save, "Saved the book without a title"
  end

  test "should not save book without author" do
    book = Book.new(title: "Test Title")
    assert_not book.save, "Saved the book without an author"
  end

  test "should save book with title and author" do
    book = Book.new(title: "Test Title", author: "Test Author")
    assert book.save, "Failed to save book with title and author"
  end

  test "average_rating should return 0 when no ratings" do
    book = Book.create!(title: "Test Title", author: "Test Author")
    assert_equal 0, book.average_rating
  end
end
