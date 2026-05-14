class DiscussionQuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_book_club_and_read
  before_action -> { authorize_discussion_question_permission }, only: [ :create, :update ]

  ##
  # Creates a discussion question for the current book read, assigning it to the current user, and responds via Turbo Stream or HTML redirect.
  # On success, emits a Turbo Stream update or redirects to the book read page with a success notice.
  # On failure, emits a Turbo Stream that replaces the new question form with the form partial and returns HTTP 422, or redirects to the book read page with an error alert.
  def create
    @discussion_question = @book_read.discussion_questions.build(discussion_question_params.merge(user: current_user))

    respond_to do |format|
      if @discussion_question.save
        format.turbo_stream
        format.html { redirect_to book_club_book_read_path(@book_club, @book_read), notice: "Question added successfully." }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.replace("new_discussion_question_form", partial: "discussion_questions/form", locals: { book_club: @book_club, book_read: @book_read, discussion_question: @discussion_question }), status: :unprocessable_entity }
        format.html { redirect_to book_club_book_read_path(@book_club, @book_read), alert: "Question cannot be blank." }
      end
    end
  end

  def update
    @discussion_question = @book_read.discussion_questions.find(params[:id])

    if @discussion_question.update(discussion_question_update_params)
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@discussion_question, partial: "discussion_questions/discussion_question", locals: { discussion_question: @discussion_question }) }
        format.html { redirect_to book_club_book_read_path(@book_club, @book_read), notice: "Question updated successfully." }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@discussion_question, partial: "discussion_questions/discussion_question", locals: { discussion_question: @discussion_question }), status: :unprocessable_entity }
        format.html { redirect_to book_club_book_read_path(@book_club, @book_read), alert: "Failed to update question." }
      end
    end
  end

  private

  def set_book_club_and_read
    @book_club = BookClub.find(params[:book_club_id])
    @book_read = @book_club.book_reads.find(params[:book_read_id])
  end

  def discussion_question_params
    params.require(:discussion_question).permit(:content)
  end

  ##
  # Strong parameters for updating a discussion question.
  # Permits the `:content` and `:status` attributes from the `discussion_question` params.
  # @return [ActionController::Parameters] Permitted parameters containing `:content` and `:status`.
  def discussion_question_update_params
    params.require(:discussion_question).permit(:content, :status)
  end

  ##
  # Ensures the current user is permitted to create or update discussion questions:
  # allows the action when the user has RSVP'd for the book read; otherwise enforces
  # club-owner authorization and redirects back to the book read page.
  def authorize_discussion_question_permission
    has_rsvp = @book_read.rsvp_users.exists?(id: current_user.id)
    return if has_rsvp

    authorize_club_owner!(@book_club, redirect_url: book_club_book_read_path(@book_club, @book_read))
  end
end
