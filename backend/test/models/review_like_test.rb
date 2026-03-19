require "test_helper"

class ReviewLikeTest < ActiveSupport::TestCase
  test "validates uniqueness of user per review" do
    # Fixture :one already has user :one liking review :one
    review_like = ReviewLike.new(user: users(:one), review: reviews(:one))
    
    assert_not review_like.valid?
    assert_includes review_like.errors[:user_id], "has already liked this review"
  end

  test "allows different users to like the same review" do
    # user :two can like review :one
    review_like = ReviewLike.new(user: users(:two), review: reviews(:one))
    
    assert review_like.valid?
  end

  test "allows same user to like different reviews" do
    # user :one can like review :two
    review_like = ReviewLike.new(user: users(:one), review: reviews(:two))
    
    assert review_like.valid?
  end
end
