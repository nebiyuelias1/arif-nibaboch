class DiscussionQuestion < ApplicationRecord
  belongs_to :book_read
  has_many :question_translations, dependent: :destroy

  # Use ZH-HANT for Traditional Chinese in DeepL, and ZH for Simplified
  TARGET_LANGUAGES = [ "ZH-HANT" ].freeze

  enum :status, { draft: 0, approved: 1, revealed: 2 }, default: :draft

  validates :content, presence: true
  validates :position, uniqueness: { scope: :book_read_id }

  before_create :set_position

  private

  def set_position
   book_read.with_lock do
      max_position = book_read.discussion_questions.maximum(:position) || 0
      self.position = max_position + 1
    end
  end
end
