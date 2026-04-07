class DiscussionQuestion < ApplicationRecord
  belongs_to :book_read

  enum :status, { draft: 0, approved: 1, revealed: 2 }, default: :draft
end
