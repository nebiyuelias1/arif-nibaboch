class ReviewLike < ApplicationRecord
  belongs_to :review, counter_cache: true
  belongs_to :user

  validates :user_id, uniqueness: { scope: :review_id, message: "has already liked this review" }
end
