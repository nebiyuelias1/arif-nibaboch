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
          start_date: Date.today,
          end_date: 1.month.from_now.to_date,
          status: "upcoming"
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
          # Missing start_date which is required, and end_date before start_date
          start_date: nil,
          end_date: 1.month.ago.to_date,
          status: "upcoming"
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
          start_date: Date.today,
          end_date: 1.month.from_now.to_date,
          status: "upcoming"
        }
      }
    end

    assert_redirected_to book_club_url(@book_club)
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end
end
