require "test_helper"

class BookReadsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

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
          meetup_time: Date.today,
          meetup_location: "Vino Vino Cafe"
        }
      }
    end

    assert_redirected_to book_club_book_read_url(@book_club, BookRead.last)
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
          meetup_time: Date.today,
          meetup_location: "Vino Vino Cafe"
        }
      }
    end

    assert_redirected_to book_club_url(@book_club)
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end

  test "should get edit for owner" do
    @book_read = book_reads(:one)
    sign_in @user
    get edit_book_club_book_read_url(@book_club, @book_read)
    assert_response :success
    assert_select "form"
  end

  test "should not get edit if not owner" do
    @book_read = book_reads(:one)
    sign_in users(:two) # User two is not the owner
    get edit_book_club_book_read_url(@book_club, @book_read)
    assert_redirected_to book_club_url(@book_club)
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end

  test "should update book_read for owner" do
    @book_read = book_reads(:one)
    sign_in @user
    new_time = 2.months.from_now.to_datetime
    patch book_club_book_read_url(@book_club, @book_read), params: {
      book_read: {
        meetup_time: new_time
      }
    }
    assert_redirected_to book_club_book_read_url(@book_club, @book_read)
    assert_equal "Book read was successfully updated.", flash[:notice]
    @book_read.reload
    # Compare with a small tolerance for database time precision
    assert_in_delta new_time.to_i, @book_read.meetup_time.to_i, 1
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
end
