class QuestionTranslation < ApplicationRecord
  belongs_to :discussion_question

  before_validation :normalize_language_code

  validates :language_code, presence: true
  validates :content, presence: true
  validates :language_code, uniqueness: {
    scope: :discussion_question_id,
    case_sensitive: false,
    message: "translation already exists for this language"
  }

  private

  def normalize_language_code
    self.language_code = language_code.strip.upcase if language_code.present?
  end
end
