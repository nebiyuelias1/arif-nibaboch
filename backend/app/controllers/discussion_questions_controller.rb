class DiscussionQuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_book_club_and_read
  before_action -> { authorize_club_owner!(@book_club, redirect_url: book_club_book_read_path(@book_club, @book_read)) }, only: [ :create, :update ]

  def create
    @discussion_question = @book_read.discussion_questions.build(discussion_question_params)

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

  def discussion_question_update_params
    params.require(:discussion_question).permit(:content, :status)
  end
end
