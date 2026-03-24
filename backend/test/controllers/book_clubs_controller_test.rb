require "test_helper"

class BookClubsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @club_params = {
      book_club: {
        name: "Sci-Fi Readers",
        description: "A club for science fiction fans.",
        is_private: false
      }
    }
  end

  test "should create club and set the current user as owner" do
    sign_in @user

    assert_difference("BookClub.count", 1) do
      post book_clubs_url, params: @club_params
    end

    created_club = BookClub.last
    assert_equal @user.id, created_club.owner_id
    assert_equal "Sci-Fi Readers", created_club.name

    assert_redirected_to book_club_url(created_club)
    assert_equal "Book Club created successfully.", flash[:notice]
  end

  test "should not create club if user is not signed in" do
    assert_no_difference("BookClub.count") do
      post book_clubs_url, params: @club_params
    end

    assert_redirected_to new_user_session_url
  end
end
