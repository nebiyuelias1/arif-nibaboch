class DiscussionQuestion < ApplicationRecord
  belongs_to :book_read
  has_many :question_translations, dependent: :destroy

  # Use ZH-HANT for Traditional Chinese in DeepL, and ZH for Simplified
  TARGET_LANGUAGES = [ "ZH-HANT" ].freeze

  enum :status, { draft: 0, approved: 1, revealed: 2 }, default: :draft

  validates :content, presence: true
  validates :position, uniqueness: { scope: :book_read_id }

  before_create :set_position
  after_commit :translate_content, on: [ :create, :update ]

  def content_for_language(lang_code)
    lang_code = lang_code.to_s.upcase

    # Normalize Chinese language codes for database lookup
    if lang_code.match?(/^ZH-(TW|HK|MO|HANT)/)
      lang_code = "ZH-HANT" # Traditional
    elsif lang_code.start_with?("ZH")
      lang_code = "ZH" # Simplified
    end

    return content if lang_code == "EN" || lang_code.blank?

    translation = question_translations.find_by(language_code: lang_code)
    translation ? translation.content : content
  end

  private

  def translate_content
    if saved_change_to_content?
      TARGET_LANGUAGES.each do |lang_code|
        TranslateDiscussionQuestionJob.perform_later(id, lang_code)
      end
    end
  end

  def set_position
   book_read.with_lock do
      max_position = book_read.discussion_questions.maximum(:position) || 0
      self.position = max_position + 1
    end
  end
end
