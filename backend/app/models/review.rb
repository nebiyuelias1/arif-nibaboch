class Review < ApplicationRecord
  belongs_to :book, counter_cache: true
  belongs_to :user
  belongs_to :parent, class_name: "Review", optional: true
  has_many :replies, class_name: "Review", foreign_key: :parent_id, dependent: :destroy
  has_many :review_likes, dependent: :destroy

  validates :body, presence: true

  validate :parent_is_not_self

  private

  def parent_is_not_self
    if parent_id.present? && parent_id == id
      errors.add(:parent_id, "cannot reference the review itself")
    end
  end
end
