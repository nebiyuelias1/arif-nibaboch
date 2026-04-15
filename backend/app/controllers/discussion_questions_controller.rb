class DiscussionQuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_book_club_and_read

  def create
    @discussion_question = @book_read.discussion_questions.build(discussion_question_params)

    respond_to do |format|
      if @discussion_question.save
        format.turbo_stream
        format.html { redirect_to book_club_book_read_path(@book_club, @book_read), notice: "Question added successfully." }
      else
        format.html { redirect_to book_club_book_read_path(@book_club, @book_read), alert: "Question cannot be blank." }
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
end
