require "test_helper"

class PollTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    @poll = polls(:one)
  end

  test "should be valid with valid attributes" do
    assert @poll.valid?
  end

  test "should require a book_read" do
    @poll.book_read = nil
    assert_not @poll.valid?
  end

  test "should require text" do
    @poll.text = nil
    assert_not @poll.valid?
    @poll.text = "   "
    assert_not @poll.valid?
  end

  test "should be valid without description" do
    @poll.description = nil
    assert @poll.valid?
  end

  test "should not be valid without end_date" do
    @poll.end_date = nil
    assert_not @poll.valid?
  end

  test "active? should be true if end_date is in the future or nil" do
    @poll.end_date = nil
    assert @poll.active?

    @poll.end_date = 1.day.from_now
    assert @poll.active?
  end

  test "active? should be false if end_date is in the past" do
    @poll.end_date = 1.day.ago
    assert_not @poll.active?
  end

  test "winning_options returns options with most votes" do
    book_read = book_reads(:one)
    poll = Poll.new(book_read: book_read, text: "Test Poll", end_date: 1.day.from_now)
    poll.poll_options.build(content: "Option 1")
    poll.poll_options.build(content: "Option 2")
    poll.save!
    option1 = poll.poll_options.first
    option2 = poll.poll_options.last
    user1 = users(:one)
    user2 = users(:two)

    # Initially all are winners if no votes
    assert_includes poll.winning_options, option1
    assert_includes poll.winning_options, option2

    # Vote for option1
    PollVote.create!(poll_option: option1, user: user1)

    assert_equal [ option1 ], poll.winning_options

    # Vote for option2 (tie)
    PollVote.create!(poll_option: option2, user: user2)

    assert_includes poll.winning_options, option1
    assert_includes poll.winning_options, option2
    assert_equal 2, poll.winning_options.size

    # One more for option1
    user4 = User.create!(email: "user4@example.com", password: "password", name: "User 4")
    PollVote.create!(poll_option: option1, user: user4)
    assert_equal [ option1 ], poll.winning_options
  end
end
