class DiscussionQuestion < ApplicationRecord
  belongs_to :book_read

  enum :status, { draft: 0, approved: 1, revealed: 2 }, default: :draft

  validates :content, presence: true

  before_create :set_position

  private

  def set_position
    max_position = book_read.discussion_questions.maximum(:position) || 0
    self.position = max_position + 1
  end
end
