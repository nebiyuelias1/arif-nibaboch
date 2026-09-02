require "test_helper"

class MembershipRequestsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @book_club = book_clubs(:one)
    @owner = users(:one)
    @non_member = users(:three)
  end

  test "creates pending request for private club without form url" do
    @book_club.update!(is_private: true, application_form_url: "https://example.com/form")

    sign_in @non_member
    assert_difference "MembershipRequest.where(status: :pending).count" do
      assert_enqueued_emails 1 do
        post book_club_membership_requests_path(@book_club)
      end
    end

    assert_redirected_to book_club_path(@book_club)
    assert_match /submitted/i, flash[:notice]
  end

  test "already pending request shows notice and does not duplicate" do
    @book_club.update!(is_private: true, application_form_url: "https://example.com/form")

    sign_in @non_member
    post book_club_membership_requests_path(@book_club)

    assert_no_difference "MembershipRequest.count" do
      post book_club_membership_requests_path(@book_club)
    end

    assert_match /pending/i, flash[:notice]
  end

  test "member cannot create request" do
    @book_club.update!(is_private: true, application_form_url: "https://example.com/form")

    sign_in @owner
    assert_no_difference "MembershipRequest.count" do
      post book_club_membership_requests_path(@book_club)
    end

    assert_match /already a member/i, flash[:notice]
  end

  test "requires authentication" do
    post book_club_membership_requests_path(@book_club)
    assert_redirected_to new_user_session_path
  end

  test "owner approves request creates membership" do
    @book_club.update!(is_private: true, application_form_url: "https://example.com/form")
    request = @book_club.membership_requests.create!(user: @non_member, status: :pending)

    sign_in @owner
    assert_enqueued_emails 1 do
      assert_difference "BookClubMember.count" do
        patch approve_book_club_membership_request_path(@book_club, request)
      end
    end

    assert_redirected_to book_club_path(@book_club)
    assert_match /approved/i, flash[:notice]
    assert request.reload.approved?
    assert @book_club.has_member?(@non_member)
  end

  test "owner rejects request does not create membership" do
    @book_club.update!(is_private: true, application_form_url: "https://example.com/form")
    request = @book_club.membership_requests.create!(user: @non_member, status: :pending)

    sign_in @owner
    assert_enqueued_emails 1 do
      assert_no_difference "BookClubMember.count" do
        patch reject_book_club_membership_request_path(@book_club, request)
      end
    end

    assert_redirected_to book_club_path(@book_club)
    assert request.reload.rejected?
    assert_not @book_club.has_member?(@non_member)
  end

  test "replayed approval is idempotent" do
    @book_club.update!(is_private: true, application_form_url: "https://example.com/form")
    request = @book_club.membership_requests.create!(user: @non_member, status: :pending)

    sign_in @owner
    patch approve_book_club_membership_request_path(@book_club, request)
    assert @book_club.has_member?(@non_member)

    assert_no_difference "BookClubMember.count" do
      assert_enqueued_emails 0 do
        patch approve_book_club_membership_request_path(@book_club, request)
      end
    end

    assert_redirected_to book_club_path(@book_club)
    assert_match /already been approved/i, flash[:notice]
  end

  test "replayed rejection is idempotent" do
    @book_club.update!(is_private: true, application_form_url: "https://example.com/form")
    request = @book_club.membership_requests.create!(user: @non_member, status: :pending)

    sign_in @owner
    patch reject_book_club_membership_request_path(@book_club, request)

    assert_no_difference "BookClubMember.count" do
      assert_enqueued_emails 0 do
        patch reject_book_club_membership_request_path(@book_club, request)
      end
    end

    assert_redirected_to book_club_path(@book_club)
    assert_match /already been rejected/i, flash[:notice]
  end

  test "turbo stream replayed approval renders no duplicate member row" do
    @book_club.update!(is_private: true, application_form_url: "https://example.com/form")
    request = @book_club.membership_requests.create!(user: @non_member, status: :pending)
    sign_in @owner

    patch approve_book_club_membership_request_path(@book_club, request), as: :turbo_stream
    assert_equal "text/vnd.turbo-stream.html", @response.media_type

    patch approve_book_club_membership_request_path(@book_club, request), as: :turbo_stream
    assert_response :no_content
  end

  test "owner can still approve a rejected request" do
    @book_club.update!(is_private: true, application_form_url: "https://example.com/form")
    request = @book_club.membership_requests.create!(user: @non_member, status: :rejected)

    sign_in @owner
    assert_difference "BookClubMember.count" do
      patch approve_book_club_membership_request_path(@book_club, request)
    end

    assert_redirected_to book_club_path(@book_club)
    assert request.reload.approved?
    assert @book_club.has_member?(@non_member)
  end

  test "turbo stream approve updates members list and pending indicator" do
    @book_club.update!(is_private: true, application_form_url: "https://example.com/form")
    request = @book_club.membership_requests.create!(user: @non_member, status: :pending)
    @book_club.membership_requests.create!(user: users(:two), status: :pending)
    sign_in @owner

    patch approve_book_club_membership_request_path(@book_club, request), as: :turbo_stream

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", @response.media_type

    # Approved request row removed, member row appended, member count updated
    assert_match /turbo-stream action="remove" target="membership_request_#{request.id}"/, @response.body
    assert_match /turbo-stream action="append" target="members_tbody"/, @response.body
    assert_match /turbo-stream action="update" targets="\[data-members-count\]"/, @response.body

    # Pending indicator badge and dialog header count stay in sync (one left)
    assert_match /turbo-stream action="update" targets="\[data-pending-requests-badge\]"/, @response.body
    assert_match /1 pending request/, @response.body
    assert_match /turbo-stream action="update" targets="\[data-pending-requests-count\]"/, @response.body
  end

  test "turbo stream handling the last pending request clears the indicator" do
    @book_club.update!(is_private: true, application_form_url: "https://example.com/form")
    request = @book_club.membership_requests.create!(user: @non_member, status: :pending)
    sign_in @owner

    patch reject_book_club_membership_request_path(@book_club, request), as: :turbo_stream

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", @response.media_type

    # Pending section emptied and the badge swap carries no badge markup
    assert_match /turbo-stream action="update" target="pending_requests_section"/, @response.body
    assert_match /turbo-stream action="update" targets="\[data-pending-requests-badge\]"/, @response.body
    assert_no_match /pending request/, @response.body
  end

  test "non-owner admin cannot approve" do
    @book_club.update!(is_private: true, application_form_url: "https://example.com/form")
    admin_member = users(:two)
    @book_club.book_club_members.create!(user: admin_member, role: :admin)
    request = @book_club.membership_requests.create!(user: @non_member, status: :pending)

    sign_in admin_member
    patch approve_book_club_membership_request_path(@book_club, request)

    assert_redirected_to book_club_path(@book_club)
    assert_match /permission/i, flash[:alert]
    assert request.reload.pending?
  end

  test "rejected user can re-apply" do
    @book_club.update!(is_private: true, application_form_url: "https://example.com/form")
    request = @book_club.membership_requests.create!(user: @non_member, status: :rejected)

    sign_in @non_member
    post book_club_membership_requests_path(@book_club)

    assert request.reload.pending?
  end

  test "user can cancel their own pending request" do
    @book_club.update!(is_private: true, application_form_url: "https://example.com/form")
    request = @book_club.membership_requests.create!(user: @non_member, status: :pending)

    sign_in @non_member
    assert_difference "MembershipRequest.count", -1 do
      delete cancel_book_club_membership_request_path(@book_club, request)
    end

    assert_redirected_to book_club_path(@book_club)
    assert_match /cancelled/i, flash[:notice]
  end

  test "user cannot cancel someone else's request" do
    @book_club.update!(is_private: true, application_form_url: "https://example.com/form")
    request = @book_club.membership_requests.create!(user: @non_member, status: :pending)

    other_user = users(:two)
    sign_in other_user
    delete cancel_book_club_membership_request_path(@book_club, request)

    assert_redirected_to book_club_path(@book_club)
    assert_match /permission/i, flash[:alert]
    assert request.reload.pending?
  end

  test "turbo stream create replaces card and show button with cancel request state" do
    @book_club.update!(is_private: true, application_form_url: "https://example.com/form")
    sign_in @non_member

    assert_difference "MembershipRequest.where(status: :pending).count" do
      post book_club_membership_requests_path(@book_club), as: :turbo_stream
    end

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", @response.media_type

    # Card wrapper (card + dialog) replaced atomically with the pending state
    assert_match /turbo-stream action="replace" target="book_club_#{@book_club.id}"/, @response.body
    assert_match /Cancel Join Request/, @response.body
    assert_no_match /id="apply_dialog_#{@book_club.id}"/, @response.body
    assert_no_match /Apply to Join/, @response.body

    # Show page join button replaced too
    assert_match /turbo-stream action="replace" target="book_club_show_join_button"/, @response.body

    # Show page apply dialog container emptied (pending state has no use for it)
    assert_match /turbo-stream action="replace" target="apply_dialog_container"><template>[\s\S]*<div id="apply_dialog_container"><\/div>/, @response.body
  end

  test "turbo stream cancel replaces card and show button with apply to join state" do
    @book_club.update!(is_private: true, application_form_url: "https://example.com/form")
    request = @book_club.membership_requests.create!(user: @non_member, status: :pending)
    sign_in @non_member

    assert_difference "MembershipRequest.count", -1 do
      delete cancel_book_club_membership_request_path(@book_club, request), as: :turbo_stream
    end

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", @response.media_type

    # Card wrapper replaced atomically: Apply button back, dialog restored
    assert_match /turbo-stream action="replace" target="book_club_#{@book_club.id}"/, @response.body
    assert_match /Apply to Join/, @response.body
    assert_match /id="apply_dialog_#{@book_club.id}"/, @response.body
    assert_no_match /Cancel Join Request/, @response.body

    # Show page join button replaced too
    assert_match /turbo-stream action="replace" target="book_club_show_join_button"/, @response.body

    # Show page apply dialog container restored
    assert_match /turbo-stream action="replace" target="apply_dialog_container"><template>[\s\S]*<dialog id="apply_dialog_#{@book_club.id}"/, @response.body
  end

  test "user can request again after cancelling and the new request is pending" do
    @book_club.update!(is_private: true, application_form_url: "https://example.com/form")
    sign_in @non_member

    # 1. Send request
    assert_difference "MembershipRequest.where(status: :pending).count" do
      post book_club_membership_requests_path(@book_club)
    end
    assert_redirected_to book_club_path(@book_club)
    assert_match /submitted/i, flash[:notice]

    first_request = @book_club.membership_requests.find_by(user: @non_member)
    assert first_request.pending?

    # 2. Cancel it
    assert_difference "MembershipRequest.count", -1 do
      delete cancel_book_club_membership_request_path(@book_club, first_request)
    end
    assert_redirected_to book_club_path(@book_club)
    assert_match /cancelled/i, flash[:notice]
    assert_nil @book_club.membership_requests.find_by(user: @non_member)

    # 3. Request again — a fresh pending request is created and the owner is notified again
    assert_difference "MembershipRequest.where(status: :pending).count" do
      assert_enqueued_emails 1 do
        post book_club_membership_requests_path(@book_club)
      end
    end
    assert_redirected_to book_club_path(@book_club)
    assert_match /submitted/i, flash[:notice]

    second_request = @book_club.membership_requests.find_by(user: @non_member)
    assert second_request.pending?
    assert_not_equal first_request.id, second_request.id
  end

  test "user can request again after an approved membership ends by leaving" do
    @book_club.update!(is_private: true, application_form_url: "https://example.com/form")
    request = @book_club.membership_requests.create!(user: @non_member, status: :pending)

    # 1. Owner approves — user becomes a member, request stays as an approved record
    sign_in @owner
    patch approve_book_club_membership_request_path(@book_club, request)
    assert @book_club.has_member?(@non_member)
    assert request.reload.approved?

    # 2. User leaves the club
    sign_in @non_member
    assert_difference "BookClubMember.count", -1 do
      post book_club_membership_url(@book_club), as: :json
    end
    assert_equal "left", JSON.parse(response.body)["status"]
    assert_not @book_club.has_member?(@non_member)

    # 3. User requests again — the stale approved record must be reset to pending
    assert_difference "MembershipRequest.where(status: :pending).count" do
      assert_enqueued_emails 1 do
        post book_club_membership_requests_path(@book_club)
      end
    end
    assert_redirected_to book_club_path(@book_club)
    assert_match /submitted/i, flash[:notice]

    assert request.reload.pending?
    assert @book_club.pending_membership_requests.exists?(user: @non_member)
  end
end
