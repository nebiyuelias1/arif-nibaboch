require "test_helper"

class QuestionTranslationTest < ActiveSupport::TestCase
  test "is invalid without a discussion_question" do
    translation = build_translation(discussion_question_id: nil)

    assert_not translation.valid?
    assert_includes translation.errors[:discussion_question], "must exist"
  end

  test "is invalid without a language_code" do
    translation = build_translation(language_code: nil)

    assert_not translation.valid?
    assert_includes translation.errors[:language_code], "can't be blank"
  end

  test "is invalid when language_code is duplicated for the same discussion_question" do
    discussion_question = discussion_questions(:one)
    existing = build_translation(discussion_question_id: discussion_question.id, language_code: "en")
    existing.save!(validate: false)

    duplicate = build_translation(discussion_question_id: discussion_question.id, language_code: "en")

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:language_code], "translation already exists for this language"
  end

  test "is valid when the same discussion_question has a different language_code" do
    discussion_question = discussion_questions(:one)
    existing = build_translation(discussion_question_id: discussion_question.id, language_code: "en")
    existing.save!(validate: false)

    translation = build_translation(discussion_question_id: discussion_question.id, language_code: "es")

    assert translation.valid?, translation.errors.full_messages.to_sentence
  end

  private

  def build_translation(overrides = {})
    QuestionTranslation.new(default_translation_attributes.merge(overrides))
  end

  def default_translation_attributes
    @default_translation_attributes ||= begin
      attrs = {}

      QuestionTranslation.columns.each do |column|
        next if %w[id created_at updated_at].include?(column.name)

        attrs[column.name] =
          case column.type
          when :string
            column.name == "language_code" ? "en" : "test"
          when :text
            "test"
          when :integer
            column.name.end_with?("_id") ? 1 : 1
          when :bigint
            column.name.end_with?("_id") ? 1 : 1
          when :float
            1.0
          when :decimal
            1
          when :boolean
            false
          when :date
            Date.current
          when :datetime, :timestamp
            Time.current
          else
            nil
          end
      end

      attrs
    end
  end
end
