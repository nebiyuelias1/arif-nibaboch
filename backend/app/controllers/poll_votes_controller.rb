class PollVotesController < ApplicationController
  prepend_before_action :store_poll_vote_return_to, only: :create
  before_action :authenticate_user!
  before_action :set_book_club
  before_action :set_book_read
  before_action :set_poll

  def create
    poll_option_ids = Array(params[:poll_option_ids]).reject(&:blank?)
    @poll_options = @poll.poll_options.includes(:poll_votes)

    if poll_option_ids.empty?
      @error_message = "Select at least one option to vote."
      return respond_with_error
    end

    options = @poll_options.select { |option| poll_option_ids.include?(option.id.to_s) }

    begin
      PollVote.transaction do
        options.each do |option|
          PollVote.create!(poll_option: option, user: current_user)
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      @error_message = e.record.errors.full_messages.to_sentence
      return respond_with_error
    end

    respond_to do |format|
      format.html { redirect_to book_club_book_read_path(@book_club, @book_read), notice: "Thanks for voting." }
      format.turbo_stream
    end
  end

  private

  def set_book_club
    @book_club = BookClub.find(params[:book_club_id])
  end

  def set_book_read
    @book_read = @book_club.book_reads.find(params[:book_read_id])
  end

  def set_poll
    @poll = @book_read.poll
  end

  def respond_with_error
    respond_to do |format|
      format.html { redirect_to book_club_book_read_path(@book_club, @book_read), alert: @error_message }
      format.turbo_stream { render :create, status: :unprocessable_entity }
    end
  end

  def store_poll_vote_return_to
    return if user_signed_in?

    store_location_for(:user, "#{book_club_book_read_path(params[:book_club_id], params[:book_read_id])}#poll_voting")
  end
end
