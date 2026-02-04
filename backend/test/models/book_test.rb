require "test_helper"

class BookTest < ActiveSupport::TestCase
  test "search finds book by title" do
    books = Book.search("Gatsby")
    assert_includes books.pluck(:title), "The Great Gatsby"
  end

  test "search finds book by title_en" do
    books = Book.search("Abebaw")
    assert_includes books.pluck(:title), "የአበባው ልጅ"
  end

  test "search finds book by title_romanized" do
    books = Book.search("Abebaw Lij")
    assert_includes books.pluck(:title), "የአበባው ልጅ"
  end

  test "search finds book by author" do
    books = Book.search("Orwell")
    assert_includes books.pluck(:title), "1984"
  end

  test "search finds book by description" do
    books = Book.search("dystopian")
    assert_includes books.pluck(:title), "1984"
  end

  test "search returns empty when query is blank" do
    books = Book.search("")
    assert_empty books
  end

  test "search returns empty when query is nil" do
    books = Book.search(nil)
    assert_empty books
  end

  test "search is case insensitive" do
    books = Book.search("gatsby")
    assert_includes books.pluck(:title), "The Great Gatsby"
  end
end
