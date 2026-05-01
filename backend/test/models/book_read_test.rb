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
    assert @book_read.valid?
  end

  test "should not require a book" do
    @book_read.book = nil
    assert @book_read.valid?
  end

  test "should not require a poll" do
    @book_read.poll = nil
    assert @book_read.valid?
  end

  test "should allow having a poll" do
    @book_read.save!
    poll = @book_read.build_poll(text: "What to read?")
    assert poll.valid?
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
