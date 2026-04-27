require "test_helper"

class PollTest < ActiveSupport::TestCase
  def setup
    @book_club = book_clubs(:one)
    @book_read = BookRead.new(
      book_club: @book_club,
      start_date: Date.today,
      book_selection_mode: "poll"
    )
    @poll = Poll.new(
      book_read: @book_read,
      title: "What book should we read next?",
      deadline: 1.week.from_now
    )
    @poll.poll_options.build(content: "Option 1")
    @poll.poll_options.build(content: "Option 2")
  end

  test "should be valid with all attributes and options" do
    assert @poll.valid?
  end

  test "should require a title" do
    @poll.title = nil
    assert_not @poll.valid?
    assert_includes @poll.errors[:title], "can't be blank"
  end

  test "should require a deadline" do
    @poll.deadline = nil
    assert_not @poll.valid?
    assert_includes @poll.errors[:deadline], "can't be blank"
  end

  test "should require at least one option" do
    @poll.poll_options.clear
    assert_not @poll.valid?
    assert_includes @poll.errors[:base], "must have at least one option"
  end

  test "should be valid with one option" do
    @poll.poll_options.clear
    @poll.poll_options.build(content: "Only Option")
    assert @poll.valid?
  end
end
