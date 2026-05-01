require "test_helper"

class PollOptionTest < ActiveSupport::TestCase
  def setup
    @poll_option = poll_options(:one)
  end

  test "should be valid with valid attributes" do
    assert @poll_option.valid?
  end

  test "should require a poll" do
    @poll_option.poll = nil
    assert_not @poll_option.valid?
  end

  test "should require a book" do
    @poll_option.book = nil
    assert_not @poll_option.valid?
  end
end
