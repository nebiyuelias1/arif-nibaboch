require "test_helper"

class ReviewTest < ActiveSupport::TestCase
  test "requires a book and a user" do
    review = Review.new

    refute review.valid?, "Review should be invalid without a book and a user"

    book_error_present = review.errors[:book].present? || review.errors[:book_id].present?
    user_error_present = review.errors[:user].present? || review.errors[:user_id].present?

    assert book_error_present, "Review should have validation errors for missing book or book_id"
    assert user_error_present, "Review should have validation errors for missing user or user_id"
  end

  test "has parent and replies associations" do
    parent_assoc = Review.reflect_on_association(:parent)
    replies_assoc = Review.reflect_on_association(:replies)

    refute_nil parent_assoc, "Review should have a :parent association"
    assert_equal :belongs_to, parent_assoc.macro, "Review :parent association should be belongs_to"

    refute_nil replies_assoc, "Review should have a :replies association"
    assert_equal :has_many, replies_assoc.macro, "Review :replies association should be has_many"
  end

  test "replies association uses dependent destroy if configured" do
    replies_assoc = Review.reflect_on_association(:replies)
    refute_nil replies_assoc, "Review should have a :replies association"

    if replies_assoc.options.key?(:dependent)
      assert_equal :destroy,
                   replies_assoc.options[:dependent],
                   "Review :replies association should use dependent: :destroy when dependent is configured"
    end
  end
end
