require "test_helper"

class TbrItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @book = books(:three) # Using book three to avoid conflicts with fixtures
    sign_in @user
  end

  test "should create tbr_item when user is signed in" do
    assert_difference("TbrItem.count") do
      post book_tbr_items_path(@book), as: :json
    end

    assert_response :success
    json_response = JSON.parse(response.body)
    assert json_response["in_tbr"]
  end

  test "should not create duplicate tbr_item" do
    # Create first TBR item
    TbrItem.create(user: @user, book: @book)

    assert_no_difference("TbrItem.count") do
      post book_tbr_items_path(@book), as: :json
    end

    # Should still succeed since it finds existing record
    assert_response :success
  end

  test "should destroy tbr_item" do
    tbr_item = TbrItem.create(user: @user, book: @book)

    assert_difference("TbrItem.count", -1) do
      delete book_tbr_item_path(@book, tbr_item), as: :json
    end

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_not json_response["in_tbr"]
  end

  test "should redirect to sign in when not authenticated" do
    sign_out @user

    post book_tbr_items_path(@book)
    assert_redirected_to new_user_session_path
  end

  test "book should show if it's in user's TBR" do
    assert_not @book.in_tbr?(@user)

    TbrItem.create(user: @user, book: @book)

    assert @book.in_tbr?(@user)
  end
end
