require "test_helper"

class PollVotesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @book_club = book_clubs(:one)
    @book_read = book_reads(:one)
    @poll = polls(:one)
    @options = @poll.poll_options
    sign_in users(:three)
  end

  test "creates votes for multiple options via turbo stream" do
    assert_difference("PollVote.count", 2) do
      post book_club_book_read_poll_votes_url(@book_club, @book_read), params: {
        poll_option_ids: @options.pluck(:id)
      }, as: :turbo_stream
    end

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", @response.media_type
    assert_match /turbo-stream action="replace" target="poll_voting"/, @response.body
  end


  test "should not create votes for with invalid ids" do
    assert_difference("PollVote.count", 0) do
      post book_club_book_read_poll_votes_url(@book_club, @book_read), params: {
        poll_option_ids: [ 404 ]
      }, as: :turbo_stream
    end

    assert_response :unprocessable_entity
  end

  test "rejects votes when poll has ended" do
    expired_poll = Poll.find(polls(:two).id)
    book_read = expired_poll.book_read
    book_club = book_read.book_club
    expired_option = PollOption.create!(poll: expired_poll, content: "Late option")

    assert_no_difference("PollVote.count") do
      post book_club_book_read_poll_votes_url(book_club, book_read), params: {
        poll_option_ids: [ expired_option.id ]
      }, as: :turbo_stream
    end

    assert_response :unprocessable_entity
  end

  test "rejects votes for expired poll via html" do
    expired_poll = Poll.find(polls(:two).id)
    book_read = expired_poll.book_read
    book_club = book_read.book_club
    expired_option = PollOption.create!(poll: expired_poll, content: "Late option")

    assert_no_difference("PollVote.count") do
      post book_club_book_read_poll_votes_url(book_club, book_read), params: {
        poll_option_ids: [ expired_option.id ]
      }
    end

    assert_redirected_to book_club_book_read_url(book_club, book_read, lang: I18n.locale)
    assert_equal "Poll has ended", flash[:alert]
  end
end
