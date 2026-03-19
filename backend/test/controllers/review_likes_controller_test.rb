require "test_helper"

class ReviewLikesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @book = books(:one)
    
    # User :one already likes review :one via fixtures
    @review = reviews(:one) 
    
    # User :two likes review :two, user :one does not
    @review_two = reviews(:two) 
    @book_two = books(:two)
  end

  test "should require authentication" do
    post book_review_like_url(@book, @review), as: :json
    assert_response :unauthorized
  end

  test "should create a new like and increment count" do
    sign_in @user
    
    assert_difference("ReviewLike.count", 1) do
      post book_review_like_url(@book_two, @review_two), as: :json
    end

    assert_response :success
    json_response = JSON.parse(response.body)
    
    assert_equal true, json_response["liked"]
    assert_equal @review_two.reload.review_likes_count, json_response["likes_count"]
  end

  test "should destroy like and decrement count if already liked" do
    sign_in @user
    
    assert_difference("ReviewLike.count", -1) do
      post book_review_like_url(@book, @review), as: :json
    end

    assert_response :success
    json_response = JSON.parse(response.body)
    
    assert_equal false, json_response["liked"]
    assert_equal @review.reload.review_likes_count, json_response["likes_count"]
  end
end
