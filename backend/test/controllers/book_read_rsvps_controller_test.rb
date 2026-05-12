require "test_helper"

class BookReadRsvpsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @book_club = book_clubs(:one)
    @book_read = book_reads(:one)
  end

  test "creates rsvp and auto-joins membership" do
    user = users(:three)
    sign_in user

    assert_difference([ "BookReadRsvp.count", "BookClubMember.count" ]) do
      post book_club_book_read_rsvp_url(@book_club, @book_read)
    end

    created_rsvp = BookReadRsvp.find_by!(book_read: @book_read, user: user)
    assert_equal user, created_rsvp.user
  end

  test "cancels rsvp via update" do
    user = users(:three)
    sign_in user
    BookReadRsvp.create!(book_read: @book_read, user: user, status: :going)

    patch book_club_book_read_rsvp_url(@book_club, @book_read), params: {
      book_read_rsvp: { status: "cancelled" }
    }

    rsvp = BookReadRsvp.find_by(book_read: @book_read, user: user)
    assert_equal "cancelled", rsvp.status
  end
end
