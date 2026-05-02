require "test_helper"

class BookReadTest < ActiveSupport::TestCase
  def setup
    @book = books(:one)
    @club = book_clubs(:one)
    @book_read = BookRead.new(
      book: @book,
      book_club: @club,
      meetup_time: 1.week.from_now,
      meetup_location: "Vino Vino Cafe",
      status: :upcoming
    )
  end

  test "should be valid with valid attributes" do
    assert @book_read.valid?
  end

  test "should require a book" do
    @book_read.book = nil
    assert_not @book_read.valid?
  end

  test "should not require a poll" do
    @book_read.poll = nil
    assert @book_read.valid?
  end

  test "should allow having a poll" do
    @book_read.save!
    poll = @book_read.build_poll(
                    text: "What to read?",
                    end_date: 1.days.from_now,
                    poll_options_attributes: [
                      { content: "Book A" },
                      { content: "Book B" }
                    ]
          )
    assert poll.valid?, poll.errors.full_messages.to_sentence
  end

  test "should require a book_club" do
    @book_read.book_club = nil
    assert_not @book_read.valid?
  end

  test "should require a meetup time" do
    @book_read.meetup_time = nil
    assert_not @book_read.valid?
  end
end
