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

  test "auto-promotes waitlisted user when going user cancels" do
    @book_read.update!(max_capacity: 2)
    going_user = users(:one)
    waitlisted_user = users(:three)
    sign_in going_user

    BookReadRsvp.create!(book_read: @book_read, user: users(:two), status: :going)
    BookReadRsvp.create!(book_read: @book_read, user: going_user, status: :going)
    waitlisted = BookReadRsvp.create!(book_read: @book_read, user: waitlisted_user, status: :waitlisted)

    assert_enqueued_emails 1 do
      patch book_club_book_read_rsvp_url(@book_club, @book_read), params: {
        book_read_rsvp: { status: "cancelled" }
      }
    end

    assert_equal "going", waitlisted.reload.status
  end

  test "sets waitlisted_count for turbo stream after rsvp" do
    @book_read.update!(max_capacity: 2)
    user = users(:three)
    sign_in user

    BookReadRsvp.create!(book_read: @book_read, user: users(:one), status: :going)
    BookReadRsvp.create!(book_read: @book_read, user: users(:two), status: :going)

    assert_enqueued_emails 0 do
      post book_club_book_read_rsvp_url(@book_club, @book_read),
           as: :turbo_stream
    end

    rsvp = BookReadRsvp.find_by!(book_read: @book_read, user: user)
    assert_equal "waitlisted", rsvp.status
    assert_match "waitlisted", response.body.downcase
  end

  test "blocks rsvp when event has passed" do
    @book_read.update_column(:meetup_time, 1.day.ago)
    user = users(:three)
    sign_in user

    assert_no_difference "BookReadRsvp.count" do
      post book_club_book_read_rsvp_url(@book_club, @book_read)
    end

    assert_redirected_to book_club_book_read_path(@book_club, @book_read)
    assert_match "closed", flash[:alert].downcase
  end

  test "blocks rsvp cancellation when event has passed" do
    @book_read.update_column(:meetup_time, 1.day.ago)
    user = users(:three)
    sign_in user
    BookReadRsvp.create!(book_read: @book_read, user: user, status: :going)

    patch book_club_book_read_rsvp_url(@book_club, @book_read), params: {
      book_read_rsvp: { status: "cancelled" }
    }

    rsvp = BookReadRsvp.find_by!(book_read: @book_read, user: user)
    assert_equal "going", rsvp.status
    assert_redirected_to book_club_book_read_path(@book_club, @book_read)
  end

  test "blocks rsvp when event has started" do
    @book_read.update_column(:meetup_time, 1.hour.ago)
    user = users(:three)
    sign_in user

    assert_no_difference "BookReadRsvp.count" do
      post book_club_book_read_rsvp_url(@book_club, @book_read)
    end

    assert_redirected_to book_club_book_read_path(@book_club, @book_read)
  end

  test "allows rsvp for future event" do
    @book_read.update!(meetup_time: 1.week.from_now)
    user = users(:three)
    sign_in user

    assert_difference "BookReadRsvp.count" do
      post book_club_book_read_rsvp_url(@book_club, @book_read)
    end
  end

  test "requires authentication for rsvp" do
    post book_club_book_read_rsvp_url(@book_club, @book_read)
    assert_redirected_to new_user_session_path
  end

  test "blocks rsvp for non-member of private club" do
    @book_club.update!(is_private: true, application_form_url: "https://example.com/form")
    @book_read.update!(meetup_time: 1.week.from_now)
    user = users(:three)
    sign_in user

    assert_no_difference([ "BookReadRsvp.count", "BookClubMember.count" ]) do
      post book_club_book_read_rsvp_url(@book_club, @book_read)
    end

    assert_redirected_to book_club_book_read_path(@book_club, @book_read)
    assert_match (/private club/i), flash[:alert]
  end

  test "allows rsvp for member of private club" do
    @book_club.update!(is_private: true, application_form_url: "https://example.com/form")
    @book_read.update!(meetup_time: 1.week.from_now)
    user = users(:one)
    sign_in user

    assert_difference "BookReadRsvp.count" do
      post book_club_book_read_rsvp_url(@book_club, @book_read)
    end
  end
end
