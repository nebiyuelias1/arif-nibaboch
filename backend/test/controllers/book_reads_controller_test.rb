require "test_helper"

class BookReadsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActiveJob::TestHelper

  setup do
    @user = users(:one)
    @book_club = book_clubs(:one)
    @book = books(:one)
  end

  test "should get new" do
    sign_in @user
    get new_book_club_book_read_url(@book_club.id)
    assert_response :success
    assert_select "form"
  end

  test "should create book_read" do
    sign_in @user
    assert_difference("BookRead.count") do
      post book_club_book_reads_url(@book_club.id), params: {
        book_read: {
          book_id: @book.id,
          book_club_id: @book_club.id,
          meetup_time: 1.week.from_now,
          meetup_location: "Vino Vino Cafe"
        }
      }
    end

    assert_redirected_to book_club_book_read_url(@book_club, BookRead.last)
    assert_equal @user, BookRead.last.host
  end

  test "should not create book_read with meetup_time in the past" do
    sign_in @user
    assert_no_difference("BookRead.count") do
      post book_club_book_reads_url(@book_club.id), params: {
        book_read: {
          book_id: @book.id,
          book_club_id: @book_club.id,
          meetup_time: 1.day.ago,
          meetup_location: "Vino Vino Cafe"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select "form"
    assert_select "div.bg-red-50", text: /cannot be in the past/i
  end

  test "should not create book_read with invalid params" do
    sign_in @user
    assert_no_difference("BookRead.count") do
      post book_club_book_reads_url(@book_club.id), params: {
        book_read: {
          book_id: @book.id,
          # Missing meetup_time which is required
          meetup_location: "Vino Vino Cafe"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select "form"
    assert_select "div.bg-red-50" # Error explanation div
  end

  test "should not get new if not owner" do
    sign_in users(:two) # user two does not own book_club one
    get new_book_club_book_read_url(@book_club.id)
    assert_redirected_to book_club_url(@book_club)
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end

  test "should not create book_read if not owner" do
    sign_in users(:two)
    assert_no_difference("BookRead.count") do
      post book_club_book_reads_url(@book_club.id), params: {
        book_read: {
          book_id: @book.id,
          book_club_id: @book_club.id,
          meetup_time: 1.week.from_now,
          meetup_location: "Vino Vino Cafe"
        }
      }
    end

    assert_redirected_to book_club_url(@book_club)
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end

  test "admin should create book_read as host" do
    admin = users(:one)

    sign_in admin
    assert_difference("BookRead.count") do
      post book_club_book_reads_url(@book_club.id), params: {
        book_read: {
          book_id: @book.id,
          book_club_id: @book_club.id,
          meetup_time: 1.week.from_now,
          meetup_location: "Vino Vino Cafe"
        }
      }
    end

    assert_equal admin, BookRead.last.host
  end

  test "should get edit for owner" do
    @book_read = book_reads(:one)
    sign_in @user
    get edit_book_club_book_read_url(@book_club, @book_read)
    assert_response :success
    assert_select "form"
  end

  test "should get edit for owner and render existing meetup_time value" do
    @book_read = book_reads(:one)
    sign_in @user
    get edit_book_club_book_read_url(@book_club, @book_read)
    assert_response :success
    assert_select "form"
    formatted_time = @book_read.meetup_time.strftime("%Y-%m-%dT%H:%M")
    assert_select "input[name='book_read[meetup_time]'][value='#{formatted_time}']"
  end

  test "should update book_read meetup_time for owner, increment sequence, and enqueue invite job" do
    @book_read = book_reads(:one)
    sign_in @user
    new_time = 2.months.from_now.to_datetime
    initial_seq = @book_read.calendar_sequence

    assert_enqueued_with(job: SendBookReadInviteJob, args: [ @book_read.id, initial_seq + 1 ]) do
      patch book_club_book_read_url(@book_club, @book_read), params: {
        book_read: {
          meetup_time: new_time
        }
      }
    end

    assert_redirected_to book_club_book_read_url(@book_club, @book_read)
    assert_equal "Book read was successfully updated.", flash[:notice]
    @book_read.reload
    assert_in_delta new_time.to_i, @book_read.meetup_time.to_i, 1
    assert_equal initial_seq + 1, @book_read.calendar_sequence
  end

  test "should not get edit if not owner" do
    @book_read = book_reads(:one)
    sign_in users(:two) # User two is not the owner
    get edit_book_club_book_read_url(@book_club, @book_read)
    assert_redirected_to book_club_url(@book_club)
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end

  test "should not update book_read if not owner" do
    @book_read = book_reads(:one)
    sign_in users(:two)
    original_time = @book_read.meetup_time
    patch book_club_book_read_url(@book_club, @book_read), params: {
      book_read: {
        meetup_time: 2.months.from_now.to_datetime
      }
    }
    assert_redirected_to book_club_url(@book_club)
    assert_equal "You are not authorized to perform this action.", flash[:alert]
    @book_read.reload
    assert_equal original_time.to_i, @book_read.meetup_time.to_i
  end

  test "should rollback transaction and preserve poll when update fails" do
    @book_read = book_reads(:one)
    poll = Poll.create!(
      book_read: @book_read,
      text: "Which book?",
      end_date: 1.day.from_now,
      poll_options_attributes: [ { content: "Option 1" }, { content: "Option 2" } ]
    )
    sign_in @user

    assert_no_difference("Poll.count") do
      patch book_club_book_read_url(@book_club, @book_read), params: {
        selection_type: "book",
        book_read: {
          meetup_location: ""
        }
      }
    end

    assert_response :unprocessable_entity
    assert Poll.exists?(poll.id)
  end

  test "should get finalize for owner" do
    @book_read = book_reads(:one)
    sign_in @user
    get finalize_book_club_book_read_url(@book_club, @book_read)
    assert_response :success
    assert_select "form"
  end

  test "should select book and finalize poll" do
    @book_read = book_reads(:one)
    @poll = polls(:one)
    @option = poll_options(:one)
    sign_in @user

    assert_nil @poll.finalized_at

    patch select_book_book_club_book_read_url(@book_club, @book_read), params: {
      poll_option_id: @option.id
    }

    assert_redirected_to book_club_book_read_url(@book_club, @book_read)
    assert_equal "Book finalized successfully.", flash[:notice]

    @book_read.reload
    @poll.reload

    assert_equal @option.book_id, @book_read.book_id
    assert_not_nil @poll.finalized_at
  end

  test "non-member cannot see meetup details of private club book read" do
    @book_club.update!(is_private: true, application_form_url: "https://example.com/form")
    @book_read = book_reads(:one)
    sign_in users(:two)

    get book_club_book_read_url(@book_club, @book_read)
    assert_response :success

    assert_select "p", text: "Vino Vino Cafe", count: 0
    assert_select "p", text: /private club/i
    assert_select "#rsvp_dialog", 0
    assert_select "#share_flyer_dialog", 0
    assert_select "form[action*='discussion_questions']", 0
  end

  test "member can see meetup details of private club book read" do
    @book_club.update!(is_private: true, application_form_url: "https://example.com/form")
    @book_read = book_reads(:one)
    sign_in @user

    get book_club_book_read_url(@book_club, @book_read)
    assert_response :success

    assert_select "p", text: "Vino Vino Cafe"
    assert_select "#rsvp_dialog"
    assert_select "#share_flyer_dialog"
  end

  test "anonymous user cannot see meetup details of private club book read" do
    @book_club.update!(is_private: true, application_form_url: "https://example.com/form")
    @book_read = book_reads(:one)

    get book_club_book_read_url(@book_club, @book_read)
    assert_response :success

    assert_select "p", text: "Vino Vino Cafe", count: 0
    assert_select "p", text: /private club/i
    assert_select "#rsvp_dialog", 0
    assert_select "#share_flyer_dialog", 0
  end

  test "non-member cannot see poll text of private club book read" do
    @book_club.update!(is_private: true, application_form_url: "https://example.com/form")
    @book_read = book_reads(:one)
    sign_in users(:two)

    get book_club_book_read_url(@book_club, @book_read)
    assert_response :success

    assert_select "p", text: "What should we read next?", count: 0
    assert_select "h2", text: "Poll"
    assert_select "p", text: /private club/i
  end

  test "member can see poll text of private club book read" do
    @book_club.update!(is_private: true, application_form_url: "https://example.com/form")
    @book_read = book_reads(:one)
    sign_in @user

    get book_club_book_read_url(@book_club, @book_read)
    assert_response :success

    assert_select "p", text: "What should we read next?"
  end
end
