class TbrItem < ApplicationRecord
  belongs_to :user
  belongs_to :book

  validates :user_id, uniqueness: { scope: :book_id, message: "has already added this book to TBR" }
end
