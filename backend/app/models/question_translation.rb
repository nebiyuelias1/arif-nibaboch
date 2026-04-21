class QuestionTranslation < ApplicationRecord
  belongs_to :discussion_question

  validates :language_code, presence: true
  validates :content, presence: true
  validates :language_code, uniqueness: { scope: :discussion_question_id, message: "translation already exists for this language" }
end
