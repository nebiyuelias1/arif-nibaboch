require "test_helper"

class DiscussionQuestionTest < ActiveSupport::TestCase
  setup do
    @book_read = book_reads(:one) # Assuming you have a book_reads fixture
  end

  test "should be valid with valid attributes" do
    question = DiscussionQuestion.new(
      book_read: @book_read,
      content: "What is the main theme of the book?",
      position: 1
    )
    assert question.valid?
  end

  test "should require a book_read" do
    question = DiscussionQuestion.new(content: "Missing book read")
    assert_not question.valid?
    assert_includes question.errors[:book_read], "must exist"
  end

  test "default status should be draft" do
    question = DiscussionQuestion.new(book_read: @book_read, content: "Test")
    assert question.draft?, "Question should default to draft status"
  end

  test "can change status to revealed" do
    question = discussion_questions(:one)
    question.revealed!

    assert question.revealed?
  end
end
