class AddEditedToDiscussionQuestions < ActiveRecord::Migration[8.0]
  def change
    add_column :discussion_questions, :edited, :boolean
  end
end
