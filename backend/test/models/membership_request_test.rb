require "test_helper"

class MembershipRequestTest < ActiveSupport::TestCase
  test "approve creates membership and sets status" do
    club = book_clubs(:one)
    user = users(:three)
    request = club.membership_requests.create!(user: user, status: :pending)

    assert_difference "BookClubMember.count" do
      request.approve!
    end

    assert request.approved?
    assert club.has_member?(user)
  end

  test "reject sets status without creating membership" do
    club = book_clubs(:one)
    user = users(:three)
    request = club.membership_requests.create!(user: user, status: :pending)

    assert_no_difference "BookClubMember.count" do
      request.reject!
    end

    assert request.rejected?
    assert_not club.has_member?(user)
  end

  test "unique per user per club" do
    club = book_clubs(:one)
    user = users(:three)
    club.membership_requests.create!(user: user, status: :pending)

    dupe = club.membership_requests.new(user: user, status: :pending)
    assert_not dupe.valid?
    assert_match(/already has a request/, dupe.errors.full_messages.join)
  end
end
