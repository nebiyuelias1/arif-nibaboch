require "test_helper"

class PollTest < ActiveSupport::TestCase
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
end
