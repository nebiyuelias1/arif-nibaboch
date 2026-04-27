require "test_helper"

class BookReadTest < ActiveSupport::TestCase
  def setup
    @book = books(:one)
    @club = book_clubs(:one)
    @book_read = BookRead.new(
      book: @book,
      book_club: @club,
      start_date: Date.today,
      end_date: 1.week.from_now,
      status: :upcoming
    )
  end

  test "should be valid with valid attributes" do
    @book_read.book_selection_mode = "book"
    assert @book_read.valid?
  end

  test "should require a book if mode is book" do
    @book_read.book_selection_mode = "book"
    @book_read.book = nil
    assert_not @book_read.valid?
    assert_includes @book_read.errors[:book_id], "must be selected"
  end

  test "should not require a book if mode is poll" do
    @book_read.book = nil
    @book_read.book_selection_mode = "poll"
    @book_read.build_poll(title: "What next?", deadline: 1.day.from_now)
    @book_read.poll.poll_options.build(content: "The Hobbit")
    assert @book_read.valid?
  end

  test "should require a poll if mode is poll" do
    @book_read.book = nil
    @book_read.book_selection_mode = "poll"
    @book_read.poll = nil
    assert_not @book_read.valid?
    assert_includes @book_read.errors[:base], "Poll must have a question"
  end

  test "should be invalid if neither book nor poll is selected when mode is blank" do
    @book_read.book_selection_mode = nil
    @book_read.book = nil
    @book_read.poll = nil
    assert_not @book_read.valid?
    assert_includes @book_read.errors[:base], "You must either select a book or create a poll"
  end


  test "should require a book_club" do
    @book_read.book_club = nil
    assert_not @book_read.valid?
  end

  test "should require a start_date" do
    @book_read.start_date = nil
    assert_not @book_read.valid?
  end


  test "should be valid without an end_date" do
    @book_read.end_date = nil
    assert @book_read.valid?
  end

  test "should be invalid if end_date is before start_date" do
    @book_read.start_date = Date.today
    @book_read.end_date = 1.day.ago
    assert_not @book_read.valid?
    assert_includes @book_read.errors[:end_date], "must be after the start date"
  end

  test "should have default status of upcoming" do
    new_read = BookRead.new
    assert_equal "upcoming", new_read.status
  end
end
