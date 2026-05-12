class BookReadRsvp < ApplicationRecord
  enum :status, { going: 0, waitlisted: 1, cancelled: 2 }

  belongs_to :book_read
  belongs_to :user

  validates :status, presence: true
  validates :user_id, uniqueness: { scope: :book_read_id }

  validate :capacity_available_for_going, if: :going?

  private

  def capacity_available_for_going
    return if book_read.max_capacity.blank?

    going_count = book_read.book_read_rsvps.going.count
    return if going_count < book_read.max_capacity

    errors.add(:base, "This session is full")
  end
end
