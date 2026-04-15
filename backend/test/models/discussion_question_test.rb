require "test_helper"

class DiscussionQuestionTest < ActiveSupport::TestCase
  setup do
    @book_read = book_reads(:one)
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

  test "position increments automatically for each new discussion question" do
    @book_read.discussion_questions.destroy_all # clear existing questions for this read only
    q1 = DiscussionQuestion.create!(book_read: @book_read, content: "First question")
    assert_equal 1, q1.position

    q2 = DiscussionQuestion.create!(book_read: @book_read, content: "Second question")
    assert_equal 2, q2.position

    q3 = DiscussionQuestion.create!(book_read: @book_read, content: "Third question")
    assert_equal 3, q3.position
  end

  test "can change status to revealed" do
    question = discussion_questions(:one)
    question.revealed!

    assert question.revealed?
  end

  test "should require content" do
    question = DiscussionQuestion.new(book_read: @book_read, content: nil)
    assert_not question.valid?
    assert_includes question.errors[:content], "can't be blank"
  end
end
