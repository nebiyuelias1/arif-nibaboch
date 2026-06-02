require "test_helper"

class DiscussionQuestionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

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

  test "should not create discussion question if not owner" do
    sign_out @user
    other_user = users(:two)
    sign_in other_user

    assert_no_difference("DiscussionQuestion.count") do
      post book_club_book_read_discussion_questions_url(@book_club, @book_read), params: {
        discussion_question: {
          content: "What did you think about the first chapter?"
        }
      }
    end

    assert_redirected_to book_club_book_read_path(@book_club, @book_read)
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end

  test "should not create discussion question with empty content via turbo stream" do
    assert_no_difference("DiscussionQuestion.count") do
      post book_club_book_read_discussion_questions_url(@book_club, @book_read), params: {
        discussion_question: {
          content: ""
        }
      }, as: :turbo_stream
    end

    assert_response :unprocessable_entity
    assert_equal "text/vnd.turbo-stream.html", @response.media_type
    assert_match /turbo-stream action="replace" target="new_discussion_question_form"/, @response.body
    assert_match /Content can&#39;t be blank/, @response.body
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

  test "should redirect unauthenticated users to sign in and preserve draft" do
    sign_out @user
    content = "Can we talk about the ending?"
    @book_read.poll = nil
    @book_read.save

    assert_no_difference("DiscussionQuestion.count") do
      post book_club_book_read_discussion_questions_url(@book_club, @book_read), params: {
        discussion_question: {
          content: content
        }
      }
    end

    assert_redirected_to new_user_session_path
    assert_equal book_club_book_read_path(@book_club, @book_read), session["user_return_to"]
    assert_equal content, session[:discussion_question_draft]

    sign_in @user
    get book_club_book_read_path(@book_club, @book_read)
    assert_response :success
    assert_includes @response.body, content
  end

  test "should delete a discussion question" do
    question = discussion_questions(:one)
    assert_difference("DiscussionQuestion.count", -1) do
      delete book_club_book_read_discussion_question_path(@book_club, @book_read, question)
    end

    assert_redirected_to book_club_book_read_path(@book_club, @book_read)
    assert_equal "Question deleted successfully.", flash[:notice]
  end

  test "should delete a discussion question via turbo stream" do
    question = discussion_questions(:one)
    assert_difference("DiscussionQuestion.count", -1) do
      delete book_club_book_read_discussion_question_path(@book_club, @book_read, question), as: :turbo_stream
    end

    assert_response :success
    assert_match /turbo-stream action="remove" target="discussion_question_#{question.id}"/, @response.body
  end

  test "should not delete discussion question if not author or admin" do
    sign_out @user
    other_user = users(:two) # not author of question :one
    sign_in other_user

    question = discussion_questions(:one)
    assert_no_difference("DiscussionQuestion.count") do
      delete book_club_book_read_discussion_question_path(@book_club, @book_read, question)
    end

    assert_redirected_to book_club_book_read_path(@book_club, @book_read)
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end

  test "author can delete their own discussion question" do
    # Sign in as user two, who authored question two
    sign_out @user
    author = users(:two)
    sign_in author
    question = discussion_questions(:two)

    assert_difference("DiscussionQuestion.count", -1) do
      delete book_club_book_read_discussion_question_path(book_clubs(:two), book_reads(:two), question)
    end

    assert_redirected_to book_club_book_read_path(book_clubs(:two), book_reads(:two))
    assert_equal "Question deleted successfully.", flash[:notice]
  end
end
