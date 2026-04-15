require "test_helper"

class DiscussionQuestionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @book_club = book_clubs(:one)
    @book_read = book_reads(:one)
    sign_in @user
  end

  test "should create discussion question" do
    assert_difference("DiscussionQuestion.count") do
      post book_club_book_read_discussion_questions_url(@book_club, @book_read), params: {
        discussion_question: {
          content: "What did you think about the first chapter?"
        }
      }
    end

    assert_redirected_to book_club_book_read_path(@book_club, @book_read)
    assert DiscussionQuestion.last.draft?
  end

  test "should create discussion question via turbo stream" do
    assert_difference("DiscussionQuestion.count") do
      post book_club_book_read_discussion_questions_url(@book_club, @book_read), params: {
        discussion_question: {
          content: "What did you think about the first chapter?"
        }
      }, as: :turbo_stream
    end

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", @response.media_type
    assert_match /turbo-stream action="append" target="discussion_questions_list"/, @response.body
    assert_match /turbo-stream action="remove" target="no_discussion_questions"/, @response.body
    assert DiscussionQuestion.last.draft?
  end

  test "should not create discussion question with empty content" do
    assert_no_difference("DiscussionQuestion.count") do
      post book_club_book_read_discussion_questions_url(@book_club, @book_read), params: {
        discussion_question: {
          content: ""
        }
      }
    end

    assert_redirected_to book_club_book_read_path(@book_club, @book_read)
    assert_equal "Question cannot be blank.", flash[:alert]
  end
end
