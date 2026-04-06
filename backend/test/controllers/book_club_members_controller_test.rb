require "test_helper"

class BookClubMembersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @book_club = book_clubs(:two)
  end

  test "should create membership if not a member" do
    sign_in @user

    assert_difference("BookClubMember.count", 1) do
      post book_club_membership_url(@book_club), as: :json
    end

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal "joined", json_response["status"]
  end

  test "should destroy membership if already a member" do
    sign_in @user

    # First join
    @book_club.book_club_members.create!(user: @user)

    assert_difference("BookClubMember.count", -1) do
      post book_club_membership_url(@book_club), as: :json
    end

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal "left", json_response["status"]
  end

  test "should require authentication to toggle membership" do
    assert_no_difference("BookClubMember.count") do
      post book_club_membership_url(@book_club), as: :json
    end

    assert_response :unauthorized
  end
end
