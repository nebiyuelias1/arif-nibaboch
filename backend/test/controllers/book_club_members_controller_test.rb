require "test_helper"

class BookClubMembersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @book_club = book_clubs(:two)
    @owner = users(:two) # Owner of book_club :two
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

  test "non-member cannot directly join private club" do
    @book_club.update!(is_private: true, application_form_url: "https://example.com/form")
    sign_in @user

    assert_no_difference("BookClubMember.count") do
      post book_club_membership_url(@book_club), as: :json
    end

    assert_response :forbidden
    assert_match (/private club/i), JSON.parse(response.body)["error"]
  end

  test "member can leave private club" do
    @book_club.update!(is_private: true, application_form_url: "https://example.com/form")
    sign_in @user
    @book_club.book_club_members.create!(user: @user)

    assert_difference("BookClubMember.count", -1) do
      post book_club_membership_url(@book_club), as: :json
    end

    assert_response :success
    assert_equal "left", JSON.parse(response.body)["status"]
  end

  test "leaving a private club shows Apply to Join on the club show page" do
    @book_club.update!(is_private: true, application_form_url: "https://example.com/form")
    sign_in @user
    @book_club.book_club_members.create!(user: @user)

    assert_difference("BookClubMember.count", -1) do
      post book_club_membership_url(@book_club)
    end

    assert_redirected_to @book_club
    follow_redirect!

    assert_response :success
    assert_not @book_club.has_member?(@user)

    # Back to non-member state: show page offers Apply to Join again
    assert_select "button#book_club_show_join_button", /Apply to Join/
    assert_select "#apply_dialog_#{@book_club.id}"
    assert_select "button", text: /Leave Club/, count: 0
  end

  test "turbo stream leave private club restores Apply to Join and the apply dialog container" do
    @book_club.update!(is_private: true, application_form_url: "https://example.com/form")
    sign_in @user
    @book_club.book_club_members.create!(user: @user)

    assert_difference("BookClubMember.count", -1) do
      post book_club_membership_url(@book_club), as: :turbo_stream
    end

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", @response.media_type

    # Card and show button both swap to the apply state, never a direct Join
    assert_match /turbo-stream action="replace" target="book_club_#{@book_club.id}"/, @response.body
    assert_match /turbo-stream action="replace" target="book_club_show_join_button"/, @response.body
    assert_match /Apply to Join/, @response.body
    assert_no_match /Join Club/, @response.body

    # The member view rendered an empty dialog container, so the leave
    # response swaps in the apply dialog — no append, no duplicate IDs
    assert_match /turbo-stream action="replace" target="apply_dialog_container"><template>[\s\S]*<dialog id="apply_dialog_#{@book_club.id}"/, @response.body
  end

  test "turbo stream blocked join attempt keeps Apply to Join and shows alert toast" do
    @book_club.update!(is_private: true, application_form_url: "https://example.com/form")
    sign_in @user

    assert_no_difference("BookClubMember.count") do
      post book_club_membership_url(@book_club), as: :turbo_stream
    end

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", @response.media_type

    # Button/card stay in the apply state — never flip to a direct Join
    assert_match /Apply to Join/, @response.body
    assert_no_match /Join Club/, @response.body

    # Nothing changed, so no dialog is delivered anywhere — only the alert toast
    assert_no_match /turbo-stream action="append" target="toast_triggers"><template>[\s\S]*<dialog id="apply_dialog_#{@book_club.id}"/, @response.body
    assert_no_match /target="apply_dialog_container"/, @response.body
    assert_match /data-flash-toast-type-value="error"/, @response.body
    assert_match /private club/i, @response.body
  end

  test "should redirect to login page and store return location if guest tries to join via html" do
    assert_no_difference("BookClubMember.count") do
      post book_club_membership_url(@book_club)
    end

    assert_redirected_to new_user_session_url
    assert_equal book_club_path(@book_club), session["user_return_to"]
  end

  test "admin can update member role" do
    sign_in @owner
    member = @book_club.book_club_members.create!(user: @user, role: :member)

    patch book_club_member_url(@book_club, member), params: { role: "admin" }

    assert_redirected_to @book_club
    assert_equal "admin", member.reload.role
  end

  test "admin can remove member" do
    sign_in @owner
    member = @book_club.book_club_members.create!(user: @user, role: :member)

    assert_difference("BookClubMember.count", -1) do
      delete book_club_member_url(@book_club, member)
    end

    assert_redirected_to @book_club
  end

  test "admin cannot update owner role" do
    sign_in @owner
    owner_membership = @book_club.book_club_members.find_by(user: @owner)

    patch book_club_member_url(@book_club, owner_membership), params: { role: "member" }

    assert_redirected_to @book_club
    assert_equal "admin", owner_membership.reload.role # still admin
  end

  test "admin cannot remove owner" do
    sign_in @owner
    owner_membership = @book_club.book_club_members.find_by(user: @owner)

    assert_no_difference("BookClubMember.count") do
      delete book_club_member_url(@book_club, owner_membership)
    end

    assert_redirected_to @book_club
  end

  test "non-admin cannot update member role" do
    sign_in @user
    @book_club.book_club_members.create!(user: @user, role: :member)
    other_user = User.create!(email: "other@example.com", password: "password", name: "Nini")
    other_membership = @book_club.book_club_members.create!(user: other_user, role: :member)

    patch book_club_member_url(@book_club, other_membership), params: { role: "admin" }

    assert_redirected_to @book_club
    assert_equal "member", other_membership.reload.role
  end

  test "non-admin cannot remove member" do
    sign_in @user
    @book_club.book_club_members.create!(user: @user, role: :member)
    other_user = User.create!(email: "other@example.com", password: "password", name: "Lidia")
    other_membership = @book_club.book_club_members.create!(user: other_user, role: :member)

    assert_no_difference("BookClubMember.count") do
      delete book_club_member_url(@book_club, other_membership)
    end

    assert_redirected_to @book_club
  end
end
