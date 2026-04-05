require "test_helper"

class BookClubTest < ActiveSupport::TestCase
  test "automatically adds owner as admin upon creation" do
    owner = users(:one)

    club = BookClub.create!(
      name: "Test Club",
      owner: owner
    )

    membership = club.book_club_members.find_by(user: owner)

    assert_not_nil membership, "Owner should have a membership record"
    assert membership.admin?, "Owner should have the admin role"
  end
end
