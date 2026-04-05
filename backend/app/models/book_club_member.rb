class BookClubMember < ApplicationRecord
  belongs_to :user
  belongs_to :book_club, counter_cache: true

  enum :role, { member: 0, admin: 1 }

  validates :user_id, uniqueness: { scope: :book_club_id, message: "is already a member of this book club" }
end
