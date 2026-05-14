class AddUserToDiscussionQuestion < ActiveRecord::Migration[8.0]
  ##
  # Adds a nullable `user` reference to the `discussion_questions` table, creating a `user_id` column, an index, and a foreign key constraint to `users`.
  # The added `user_id` column permits NULL values.
  def change
    add_reference :discussion_questions, :user, null: true, index: true, foreign_key: true
  end
end
