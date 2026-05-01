require "test_helper"

class PollVoteTest < ActiveSupport::TestCase
  def setup
    @poll_vote = poll_votes(:one)
  end

  test "should be valid with valid attributes" do
    assert @poll_vote.valid?
  end

  test "should require a poll_option" do
    @poll_vote.poll_option = nil
    assert_not @poll_vote.valid?
  end

  test "should require a user" do
    @poll_vote.user = nil
    assert_not @poll_vote.valid?
  end

  test "should prevent a user from voting twice for the same option" do
    duplicate_vote = @poll_vote.dup
    assert_not duplicate_vote.valid?
    assert_includes duplicate_vote.errors[:user_id], "has already voted for this option"
  end
end
