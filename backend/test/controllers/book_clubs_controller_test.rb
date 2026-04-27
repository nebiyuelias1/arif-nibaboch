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

  test "should create a membership record when user creates club" do
    sign_in @user

    post book_clubs_url, params: @club_params

    created_club = BookClub.last
    assert_equal 1, created_club.book_club_members_count
    membership = created_club.book_club_members.find_by(user: @user)

    assert_not_nil membership
    assert membership.admin?
  end

  test "should not create club if user is not signed in" do
    assert_no_difference("BookClub.count") do
      post book_clubs_url, params: @club_params
    end

    assert_redirected_to new_user_session_url
  end

  test "should get edit for owner" do
    @club = book_clubs(:one)
    sign_in @user # User one is the owner
    get edit_book_club_url(@club)
    assert_response :success
  end

  test "should not get edit for non-owner" do
    @club = book_clubs(:two) # User two is the owner
    sign_in @user # User one
    get edit_book_club_url(@club)
    assert_redirected_to book_club_url(@club)
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end

  test "should not get edit if not signed in" do
    @club = book_clubs(:one)
    get edit_book_club_url(@club)
    assert_redirected_to new_user_session_url
  end

  test "should update club for owner" do
    @club = book_clubs(:one)
    sign_in @user
    patch book_club_url(@club), params: {
      book_club: {
        name: "Updated Club Name",
        description: "New updated description",
        is_private: true
      }
    }
    assert_redirected_to book_club_url(@club)
    assert_equal "Book Club updated successfully.", flash[:notice]

    @club.reload
    assert_equal "Updated Club Name", @club.name
    assert_equal "New updated description", @club.description
    assert_equal true, @club.is_private
  end
end
