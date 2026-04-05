require "test_helper"

class BookClubMemberTest < ActiveSupport::TestCase
  test "should not allow duplicate memberships" do
    user = users(:one)
    book_club = book_clubs(:two)

    # Ensure there is no existing membership
    BookClubMember.where(user: user, book_club: book_club).destroy_all

    # Create the first membership
    assert_difference("BookClubMember.count", 1) do
      BookClubMember.create!(user: user, book_club: book_club)
    end

    # Attempt to create a duplicate
    duplicate_member = BookClubMember.new(user: user, book_club: book_club)

    assert_not duplicate_member.valid?, "Duplicate membership should be invalid"
    assert_includes duplicate_member.errors[:user_id], "is already a member of this book club"
  end
end
